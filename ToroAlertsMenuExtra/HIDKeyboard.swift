//
//  HIDKeyboard.swift
//  ToroAlertsMenuExtra
//
//  Created by digdog on 2/6/26.
//

import Foundation
import IOKit
import IOKit.hid
import Synchronization

// MARK: - HIDKeyboard

/// Low-level IOKit keyboard monitor. Produces raw key events via an AsyncStream continuation.
///
/// Usage:
/// ```swift
/// let (stream, continuation) = AsyncStream<HIDKeyboard.RawKeyEvent>.makeStream()
/// HIDKeyboard.shared.startMonitoring(continuation: continuation)
/// for await event in stream { ... }
/// ```
class HIDKeyboard {

    static let shared = HIDKeyboard()

    /// A raw HID key event.
    struct RawKeyEvent: Sendable {
        let keyCode: HIDKeyCode
        let pressed: Bool
    }

    // MARK: - State

    private struct State: @unchecked Sendable {
        var pressedKeys: Set<HIDKeyCode> = []
        var eventContinuation: AsyncStream<RawKeyEvent>.Continuation?
    }

    private let state = Mutex(State())
    private var hidManager: IOHIDManager?

    private init() {}

    deinit {
        stopMonitoring()
    }

    // MARK: - Public

    /// `true` if the IOHIDManager is currently open and monitoring.
    var isMonitoring: Bool { hidManager != nil }

    /// Opens the IOHIDManager and begins receiving global key events.
    /// Requires "Input Monitoring" permission (System Settings > Privacy & Security).
    ///
    /// - Parameter continuation: The continuation to yield raw key events into.
    func startMonitoring(continuation: AsyncStream<RawKeyEvent>.Continuation) {
        guard hidManager == nil else { return }

        state.withLock { $0.eventContinuation = continuation }

        let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        hidManager = manager

        // Match keyboard devices (GenericDesktop / Keyboard)
        let keyboardMatch: [String: Any] = [
            kIOHIDDeviceUsagePageKey as String: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey as String: kHIDUsage_GD_Keyboard
        ]
        // Match keypad devices (GenericDesktop / Keypad)
        let keypadMatch: [String: Any] = [
            kIOHIDDeviceUsagePageKey as String: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey as String: kHIDUsage_GD_Keypad
        ]
        IOHIDManagerSetDeviceMatchingMultiple(manager, [keyboardMatch, keypadMatch] as CFArray)

        // Register input value callback
        let context = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerRegisterInputValueCallback(manager, Self.hidInputValueCallback, context)

        // Schedule on main run loop
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)

        // Open
        let result = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        if result != kIOReturnSuccess {
            stopMonitoring()
        }
    }

    /// Closes the IOHIDManager and stops monitoring.
    func stopMonitoring() {
        guard let manager = hidManager else { return }

        IOHIDManagerRegisterInputValueCallback(manager, nil, nil)
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))

        state.withLock { state in
            state.pressedKeys.removeAll()
            state.eventContinuation?.finish()
            state.eventContinuation = nil
        }
        hidManager = nil
    }

    // MARK: - Internal (called from C callback)

    /// Handles raw HID value, filters duplicate press/release via pressedKeys, yields to continuation.
    private func handleRawKeyChange(keyCode: HIDKeyCode, pressed: Bool) {
        state.withLock { state in
            if pressed {
                guard !state.pressedKeys.contains(keyCode) else { return }
                state.pressedKeys.insert(keyCode)
            } else {
                guard state.pressedKeys.contains(keyCode) else { return }
                state.pressedKeys.remove(keyCode)
            }
            state.eventContinuation?.yield(RawKeyEvent(keyCode: keyCode, pressed: pressed))
        }
    }

    // MARK: - C Callback

    /// C-compatible static callback for IOHIDManager input values.
    private static let hidInputValueCallback: IOHIDValueCallback = { context, result, sender, value in
        guard let context else { return }

        let element = IOHIDValueGetElement(value)
        let usagePage = IOHIDElementGetUsagePage(element)
        let usage = IOHIDElementGetUsage(element)

        // Only process Keyboard/Keypad page (0x07)
        guard usagePage == 0x07 else { return }

        // Valid USB HID keyboard usage range: 0x04 (KeyA) through 0xE7 (Right GUI)
        guard usage >= 0x04, usage <= 0xE7 else { return }

        let pressed = IOHIDValueGetIntegerValue(value) != 0
        let keyCode = HIDKeyCode(rawValue: Int(usage))

        let keyboard = Unmanaged<HIDKeyboard>.fromOpaque(context).takeUnretainedValue()
        keyboard.handleRawKeyChange(keyCode: keyCode, pressed: pressed)
    }
}
