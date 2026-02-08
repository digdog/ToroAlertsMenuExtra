//
//  KeyEventMapper.swift
//  ToroAlertsMenuExtra
//
//  Created by digdog on 2/7/26.
//

import Foundation
import ToroAlerts

/// Translates keyboard events into device commands.
///
/// Each HID key-down event arrives as a ``KeySide`` (which half of the keyboard
/// was pressed) plus an optional ``Duration`` (time since the previous key-down).
/// The mapper turns these into a ``DeviceRequest`` (what the device should do) and
/// an output ``Duration`` (how fast it should do it).
///
/// ## Input → Output
///
/// ```
/// ┌─────────────────────────────┐         ┌────────────────────────────┐
/// │  Input (per key-down)       │         │  Output (Result?)          │
/// │                             │  map()  │                            │
/// │  side: KeySide              │────────▶│  request: DeviceRequest    │
/// │  typingInterval: Duration?  │         │  interval: Duration        │
/// └─────────────────────────────┘         └────────────────────────────┘
/// ```
///
/// - `side` — which region of the keyboard was pressed:
///   `.left` (A–G, Q–T, …), `.right` (H–P, 6–0, …), `.both` (space bar),
///   or `.none` (unmapped key, ignored).
/// - `typingInterval` — elapsed time since the previous key-down, measured by
///   `ContinuousClock`. `nil` on the very first press. Values < 10 ms are
///   filtered upstream as key bounce.
///
/// ## Pattern Recognition
///
/// The mapper is **stateful**. It remembers recent presses and detects two patterns,
/// both requiring `triggerCount` (3) consecutive qualifying presses:
///
/// ```
/// Pattern            Example sequence    Fires on     Resulting request
/// ─────────────────  ──────────────────  ───────────  ─────────────────
/// Consecutive same   R  R  R             3rd press    .rightTriple
///                    ⎵  ⎵  ⎵            3rd press    .bothTriple
///                    ⎵  ⎵  ⎵  ⎵         4th press    .bothQuad
/// Alternating L/R    L  R  L             3rd press    .lrlrlr
///                    R  L  R             3rd press    .rlrlrl
/// No pattern         L                   immediately  .left
///                    R                   immediately  .right
///                    ⎵                   immediately  .both
/// ```
///
/// ## Interval Mapping
///
/// The output interval controls device movement speed and is derived from the
/// user's typing tempo:
///
/// ```
/// Typing speed        Output interval    Behavior
/// ──────────────────  ─────────────────  ────────────────────
/// First press (nil)   500 ms             Moderate default
/// Very fast (< 50 ms) 50 ms (floor)      Clamped to minimum
/// Normal typing       ≈ typingInterval   Mirrors user speed
/// Slow (> 1000 ms)    1000 ms (ceiling)  Clamped to maximum
/// Multi-press burst   burst ÷ moves      Spread evenly
/// ```
///
/// For multi-press requests the mapper sums the last `triggerCount` intervals
/// (the burst window) and divides by `movementCount`, so the total device
/// movement time approximates the user's actual burst duration.
///

struct KeyEventMapper {

    /// The output of ``map(side:typingInterval:)``.
    ///
    /// - `request`: the device command to execute.
    /// - `interval`: per-movement duration the device should use.
    struct Result {
        let request: DeviceRequest
        let interval: Duration
    }

    // MARK: - Configuration

    /// Number of qualifying presses required to trigger a multi-press or
    /// alternating pattern. Also used as the sliding-window size for recent
    /// interval tracking.
    private let triggerCount = 3

    /// Allowed range for the output interval. Typing intervals outside this
    /// range are clamped to the nearest bound.
    private let intervalRange: ClosedRange<Duration> = .milliseconds(50)...(.milliseconds(1000))

    /// Output interval used when no prior key-down exists (`typingInterval` is `nil`).
    private let defaultInterval: Duration = .milliseconds(500)

    // MARK: - State (reset implicitly — mapper lives for the app's lifetime)

    private var alternatingCount = 0       // running count of L↔R alternations
    private var prevSide: KeySide = .none  // last side seen (for alternating detection)
    private var consecutiveCount = 0       // running count of same-side presses
    private var consecutiveSide: KeySide = .none  // which side is being repeated
    private var recentIntervals: [Duration] = []  // sliding window (≤ triggerCount entries)

    // MARK: - Public API

    /// Maps a single key-down event to a device command.
    ///
    /// - Parameters:
    ///   - side: Which keyboard region was pressed.
    ///   - typingInterval: Time elapsed since the previous key-down, or `nil` for the first press.
    /// - Returns: A ``Result`` containing the resolved request and interval,
    ///   or `nil` if the event should be ignored (`.none` side or `.noop` request).
    mutating func map(side: KeySide, typingInterval: Duration?) -> Result? {
        guard side != .none else { return nil }

        // Track recent intervals
        if let interval = typingInterval {
            recentIntervals.append(interval)
            if recentIntervals.count > triggerCount {
                recentIntervals.removeFirst()
            }
        }

        let request = resolveRequest(side: side)
        guard request != .noop else { return nil }

        // Multi-press: total device time ≈ typing burst duration
        let interval: Duration
        if request.isMultiPress, !recentIntervals.isEmpty {
            let burstDuration = recentIntervals.reduce(.zero, +)
            interval = clampedInterval(burstDuration, movementCount: request.movementCount)
        } else {
            interval = clampedInterval(typingInterval)
        }

        return Result(request: request, interval: interval)
    }

    // MARK: - Interval Calculation

    /// Converts a raw typing interval into a per-movement device interval,
    /// clamped to ``intervalRange``.

    private func clampedInterval(_ typingInterval: Duration?, movementCount: Int = 1) -> Duration {
        guard let typingInterval else {
            return defaultInterval
        }
        let perMovement = typingInterval / movementCount
        return max(intervalRange.lowerBound, min(intervalRange.upperBound, perMovement))
    }

    // MARK: - Pattern Detection & Request Resolution

    /// Determines which ``DeviceRequest`` to emit based on accumulated state.
    ///
    /// Priority order: alternating pattern > consecutive multi-press > basic 1:1 mapping.

    private mutating func resolveRequest(side: KeySide) -> DeviceRequest {
        // Update consecutive counter
        if side == consecutiveSide {
            consecutiveCount += 1
        } else {
            consecutiveCount = 1
            consecutiveSide = side
        }

        // Alternating pattern check (L-R-L or R-L-R)
        if isAlternatingTriggered(currentSide: side) {
            alternatingCount = 0
            prevSide = side
            return side == .left ? .lrlrlr : .rlrlrl
        }
        updateAlternating(currentSide: side)

        // Count-based multi-press variants
        switch side {
        case .right:
            if consecutiveCount >= triggerCount {
                return .rightTriple
            }
        case .both:
            if consecutiveCount >= triggerCount + 1 {
                return .bothQuad
            }
            if consecutiveCount >= triggerCount {
                return .bothTriple
            }
        default:
            break
        }

        return basicRequest(for: side)
    }

    private func basicRequest(for side: KeySide) -> DeviceRequest {
        switch side {
        case .left:  .left
        case .right: .right
        case .both:  .both
        case .none:  .noop
        }
    }

    // MARK: - Alternating Pattern (L↔R detection)

    /// Returns `true` when the current press completes a full L-R-L or R-L-R alternation
    /// of length `triggerCount`.

    private func isAlternatingTriggered(currentSide: KeySide) -> Bool {
        guard currentSide == .left || currentSide == .right else { return false }
        guard prevSide == .left || prevSide == .right else { return false }
        guard currentSide != prevSide else { return false }
        return alternatingCount + 1 >= triggerCount
    }

    private mutating func updateAlternating(currentSide: KeySide) {
        guard currentSide == .left || currentSide == .right else {
            alternatingCount = 0
            prevSide = currentSide
            return
        }

        if prevSide == .left || prevSide == .right {
            if currentSide != prevSide {
                alternatingCount += 1
            } else {
                alternatingCount = 0
            }
        }

        prevSide = currentSide
    }
}

// MARK: - DeviceRequest Helpers

extension DeviceRequest {
    /// Whether this request represents a multi-press pattern that should spread
    /// its interval across multiple movements.
    var isMultiPress: Bool {
        switch self {
        case .rightTriple, .bothTriple, .bothQuad, .lrlrlr, .rlrlrl:
            true
        default:
            false
        }
    }

    /// Number of discrete device movements this request produces.
    /// Used to divide a burst duration into per-movement intervals.
    var movementCount: Int {
        switch self {
        case .noop:        0
        case .left:        1
        case .right:       1
        case .both:        1
        case .rl:          2
        case .rightTriple: 3
        case .bothTriple:  3
        case .bothQuad:    4
        case .lrlrlr:      6
        case .rlrlrl:      6
        }
    }
}
