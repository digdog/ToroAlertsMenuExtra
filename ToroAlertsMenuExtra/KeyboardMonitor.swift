//
//  KeyboardMonitor.swift
//  ToroAlertsMenuExtra
//
//  Created by digdog on 2/6/26.
//

import AsyncAlgorithms
import Foundation
import Observation
import Synchronization
import ToroAlerts

enum KeySide {
    case left
    case right
    case both   // Space bar
    case none   // Unmapped key
}

/// Events produced by `KeyboardMonitor` for external consumers.
enum KeyboardMonitorEvent: Sendable {
    /// A mapped device action ready to be yielded to `DeviceCoordinator`.
    case deviceAction(DeviceRequest, Duration)
    /// UI requested device reconnection.
    case reconnectRequested
}

@Observable
@MainActor
class KeyboardMonitor {

    // MARK: - Observable UI state

    var leftActive = false
    var rightActive = false
    var typingInterval: TimeInterval = 0.0
    var typingSpeed: Double = 0.0
    var isMonitoring = false
    var isConnected = false
    var connectionError: String?

    // MARK: - Non-observable state

    @ObservationIgnored var lastSide: KeySide = .none
    @ObservationIgnored private var lastKeyTime: ContinuousClock.Instant?
    @ObservationIgnored private var resetContinuation: AsyncStream<Void>.Continuation?
    @ObservationIgnored private var resetDebounceTask: Task<Void, Never>?
    @ObservationIgnored private var flashContinuation: AsyncStream<Void>.Continuation?
    @ObservationIgnored private var flashDebounceTask: Task<Void, Never>?
    @ObservationIgnored private var processingTask: Task<Void, Never>?
    @ObservationIgnored private var mapper = KeyEventMapper()

    /// Single-consumer event continuation.
    @ObservationIgnored private let eventContinuation = Mutex<AsyncStream<KeyboardMonitorEvent>.Continuation?>(nil)

    // MARK: - Lifecycle

    func start() {
        guard processingTask == nil else { return }

        let (rawStream, rawContinuation) = AsyncStream<HIDKeyboard.RawKeyEvent>.makeStream(
            bufferingPolicy: .unbounded
        )

        HIDKeyboard.shared.startMonitoring(continuation: rawContinuation)

        if HIDKeyboard.shared.isMonitoring {
            isMonitoring = true
        }

        processingTask = Task { [weak self] in
            for await rawEvent in rawStream {
                guard let self, !Task.isCancelled else { break }
                self.handleHIDKeyChange(keyCode: rawEvent.keyCode, pressed: rawEvent.pressed)
            }
        }

        let (resetStream, resetCont) = AsyncStream<Void>.makeStream()
        resetContinuation = resetCont
        resetDebounceTask = Task {
            for await _ in resetStream.debounce(for: .seconds(2)) {
                typingInterval = 0.0
                typingSpeed = 0.0
                lastKeyTime = nil
            }
        }

        let (flashStream, flashCont) = AsyncStream<Void>.makeStream()
        flashContinuation = flashCont
        flashDebounceTask = Task {
            for await _ in flashStream.debounce(for: .milliseconds(200)) {
                leftActive = false
                rightActive = false
            }
        }
    }

    func stop() {
        processingTask?.cancel()
        processingTask = nil

        HIDKeyboard.shared.stopMonitoring()
        isMonitoring = false
        eventContinuation.withLock {
            $0?.finish()
            $0 = nil
        }

        lastSide = .none
        typingInterval = 0.0
        typingSpeed = 0.0
        lastKeyTime = nil
        resetContinuation?.finish()
        resetContinuation = nil
        resetDebounceTask?.cancel()
        resetDebounceTask = nil

        flashContinuation?.finish()
        flashContinuation = nil
        flashDebounceTask?.cancel()
        flashDebounceTask = nil
    }

    /// Called by UI to attempt device reconnection.
    func connect() {
        connectionError = nil
        yieldEvent(.reconnectRequested)
    }

    // MARK: - Event Stream

    /// Creates the event stream. Single consumer — calling again replaces the previous stream.
    nonisolated func newEventStream() -> AsyncStream<KeyboardMonitorEvent> {
        let (stream, continuation) = AsyncStream<KeyboardMonitorEvent>.makeStream(
            bufferingPolicy: .unbounded
        )
        eventContinuation.withLock { old in
            old?.finish()
            old = continuation
        }
        continuation.onTermination = { [weak self] _ in
            self?.eventContinuation.withLock { $0 = nil }
        }
        return stream
    }

    // MARK: - Private: Event Yielding

    private nonisolated func yieldEvent(_ event: KeyboardMonitorEvent) {
        _ = eventContinuation.withLock { $0?.yield(event) }
    }

    // MARK: - HID Handling

    private func handleHIDKeyChange(keyCode: HIDKeyCode, pressed: Bool) {
        guard pressed else { return }

        let side = keyCode.side
        guard side != .none else { return }

        lastSide = side
        flash(side: side)

        let now = ContinuousClock.now
        var keyInterval: Duration? = nil

        if let previous = lastKeyTime {
            let elapsed = previous.duration(to: now)
            if elapsed < .milliseconds(10) {
                return
            }
            keyInterval = elapsed
            updateTypingSpeed(now: now, interval: elapsed)
        } else {
            updateTypingSpeed(now: now, interval: nil)
        }

        // Map and broadcast device action
        if let result = mapper.map(side: side, typingInterval: keyInterval) {
            yieldEvent(.deviceAction(result.request, result.interval))
        }
    }

    // MARK: - Flash

    private func flash(side: KeySide) {
        switch side {
        case .left:
            leftActive = true
            rightActive = false
        case .right:
            leftActive = false
            rightActive = true
        case .both:
            leftActive = true
            rightActive = true
        case .none:
            return
        }
        flashContinuation?.yield()
    }

    // MARK: - Typing speed

    private func updateTypingSpeed(now: ContinuousClock.Instant, interval: Duration?) {
        if let interval {
            let seconds = Double(interval.components.seconds) + Double(interval.components.attoseconds) * 1e-18
            typingInterval = seconds * 1000
            typingSpeed = 1.0 / seconds
        }
        lastKeyTime = now

        resetContinuation?.yield()
    }
}
