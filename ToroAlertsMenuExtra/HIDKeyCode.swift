//
//  HIDKeyCode.swift
//  ToroAlertsMenuExtra
//
//  Created by digdog on 2/6/26.
//

import Foundation

/// USB HID Usage Table - Keyboard/Keypad Page (0x07)
/// Mirrors the GameController `GCKeyCode` API pattern.
struct HIDKeyCode: Hashable, Sendable {
    let rawValue: Int

    // MARK: - Letters (0x04-0x1D)

    static let keyA = HIDKeyCode(rawValue: 0x04)
    static let keyB = HIDKeyCode(rawValue: 0x05)
    static let keyC = HIDKeyCode(rawValue: 0x06)
    static let keyD = HIDKeyCode(rawValue: 0x07)
    static let keyE = HIDKeyCode(rawValue: 0x08)
    static let keyF = HIDKeyCode(rawValue: 0x09)
    static let keyG = HIDKeyCode(rawValue: 0x0A)
    static let keyH = HIDKeyCode(rawValue: 0x0B)
    static let keyI = HIDKeyCode(rawValue: 0x0C)
    static let keyJ = HIDKeyCode(rawValue: 0x0D)
    static let keyK = HIDKeyCode(rawValue: 0x0E)
    static let keyL = HIDKeyCode(rawValue: 0x0F)
    static let keyM = HIDKeyCode(rawValue: 0x10)
    static let keyN = HIDKeyCode(rawValue: 0x11)
    static let keyO = HIDKeyCode(rawValue: 0x12)
    static let keyP = HIDKeyCode(rawValue: 0x13)
    static let keyQ = HIDKeyCode(rawValue: 0x14)
    static let keyR = HIDKeyCode(rawValue: 0x15)
    static let keyS = HIDKeyCode(rawValue: 0x16)
    static let keyT = HIDKeyCode(rawValue: 0x17)
    static let keyU = HIDKeyCode(rawValue: 0x18)
    static let keyV = HIDKeyCode(rawValue: 0x19)
    static let keyW = HIDKeyCode(rawValue: 0x1A)
    static let keyX = HIDKeyCode(rawValue: 0x1B)
    static let keyY = HIDKeyCode(rawValue: 0x1C)
    static let keyZ = HIDKeyCode(rawValue: 0x1D)

    // MARK: - Numbers (0x1E-0x27)

    static let one   = HIDKeyCode(rawValue: 0x1E)
    static let two   = HIDKeyCode(rawValue: 0x1F)
    static let three = HIDKeyCode(rawValue: 0x20)
    static let four  = HIDKeyCode(rawValue: 0x21)
    static let five  = HIDKeyCode(rawValue: 0x22)
    static let six   = HIDKeyCode(rawValue: 0x23)
    static let seven = HIDKeyCode(rawValue: 0x24)
    static let eight = HIDKeyCode(rawValue: 0x25)
    static let nine  = HIDKeyCode(rawValue: 0x26)
    static let zero  = HIDKeyCode(rawValue: 0x27)

    // MARK: - Punctuation & Command (0x28-0x38)

    static let returnOrEnter    = HIDKeyCode(rawValue: 0x28)
    static let escape           = HIDKeyCode(rawValue: 0x29)
    static let deleteOrBackspace = HIDKeyCode(rawValue: 0x2A)
    static let tab              = HIDKeyCode(rawValue: 0x2B)
    static let spacebar         = HIDKeyCode(rawValue: 0x2C)
    static let hyphen           = HIDKeyCode(rawValue: 0x2D)
    static let equalSign        = HIDKeyCode(rawValue: 0x2E)
    static let openBracket      = HIDKeyCode(rawValue: 0x2F)
    static let closeBracket     = HIDKeyCode(rawValue: 0x30)
    static let backslash        = HIDKeyCode(rawValue: 0x31)
    // 0x32 = Non-US # (rarely used)
    static let semicolon        = HIDKeyCode(rawValue: 0x33)
    static let quote            = HIDKeyCode(rawValue: 0x34)
    static let graveAccentAndTilde = HIDKeyCode(rawValue: 0x35)
    static let comma            = HIDKeyCode(rawValue: 0x36)
    static let period           = HIDKeyCode(rawValue: 0x37)
    static let slash            = HIDKeyCode(rawValue: 0x38)

    // MARK: - Caps Lock & Function Keys (0x39-0x45)

    static let capsLock = HIDKeyCode(rawValue: 0x39)
    static let F1  = HIDKeyCode(rawValue: 0x3A)
    static let F2  = HIDKeyCode(rawValue: 0x3B)
    static let F3  = HIDKeyCode(rawValue: 0x3C)
    static let F4  = HIDKeyCode(rawValue: 0x3D)
    static let F5  = HIDKeyCode(rawValue: 0x3E)
    static let F6  = HIDKeyCode(rawValue: 0x3F)
    static let F7  = HIDKeyCode(rawValue: 0x40)
    static let F8  = HIDKeyCode(rawValue: 0x41)
    static let F9  = HIDKeyCode(rawValue: 0x42)
    static let F10 = HIDKeyCode(rawValue: 0x43)
    static let F11 = HIDKeyCode(rawValue: 0x44)
    static let F12 = HIDKeyCode(rawValue: 0x45)

    // MARK: - Navigation (0x49-0x52)

    static let insert       = HIDKeyCode(rawValue: 0x49)
    static let home         = HIDKeyCode(rawValue: 0x4A)
    static let pageUp       = HIDKeyCode(rawValue: 0x4B)
    static let deleteForward = HIDKeyCode(rawValue: 0x4C)
    static let end          = HIDKeyCode(rawValue: 0x4D)
    static let pageDown     = HIDKeyCode(rawValue: 0x4E)
    static let rightArrow   = HIDKeyCode(rawValue: 0x4F)
    static let leftArrow    = HIDKeyCode(rawValue: 0x50)
    static let downArrow    = HIDKeyCode(rawValue: 0x51)
    static let upArrow      = HIDKeyCode(rawValue: 0x52)

    // MARK: - Keypad (0x53-0x63, 0x67)

    static let keypadNumLock  = HIDKeyCode(rawValue: 0x53)
    static let keypadSlash    = HIDKeyCode(rawValue: 0x54)
    static let keypadAsterisk = HIDKeyCode(rawValue: 0x55)
    static let keypadHyphen   = HIDKeyCode(rawValue: 0x56)
    static let keypadPlus     = HIDKeyCode(rawValue: 0x57)
    static let keypadEnter    = HIDKeyCode(rawValue: 0x58)
    static let keypad1        = HIDKeyCode(rawValue: 0x59)
    static let keypad2        = HIDKeyCode(rawValue: 0x5A)
    static let keypad3        = HIDKeyCode(rawValue: 0x5B)
    static let keypad4        = HIDKeyCode(rawValue: 0x5C)
    static let keypad5        = HIDKeyCode(rawValue: 0x5D)
    static let keypad6        = HIDKeyCode(rawValue: 0x5E)
    static let keypad7        = HIDKeyCode(rawValue: 0x5F)
    static let keypad8        = HIDKeyCode(rawValue: 0x60)
    static let keypad9        = HIDKeyCode(rawValue: 0x61)
    static let keypad0        = HIDKeyCode(rawValue: 0x62)
    static let keypadPeriod   = HIDKeyCode(rawValue: 0x63)
    static let keypadEqualSign = HIDKeyCode(rawValue: 0x67)

    // MARK: - ISO

    static let nonUSBackslash = HIDKeyCode(rawValue: 0x64) // Section key (§)

    // MARK: - JIS / International

    static let international1 = HIDKeyCode(rawValue: 0x87) // ろ (Underscore)
    static let international3 = HIDKeyCode(rawValue: 0x89) // ¥ (Yen)
    static let lang1 = HIDKeyCode(rawValue: 0x90) // Kana (かな)
    static let lang2 = HIDKeyCode(rawValue: 0x91) // Eisu (英数)

    // MARK: - Left-Side Modifiers (0xE0-0xE3)

    static let leftControl = HIDKeyCode(rawValue: 0xE0)
    static let leftShift   = HIDKeyCode(rawValue: 0xE1)
    static let leftAlt     = HIDKeyCode(rawValue: 0xE2)
    static let leftGUI     = HIDKeyCode(rawValue: 0xE3)

    // MARK: - Right-Side Modifiers (0xE4-0xE7)

    static let rightControl = HIDKeyCode(rawValue: 0xE4)
    static let rightShift   = HIDKeyCode(rawValue: 0xE5)
    static let rightAlt     = HIDKeyCode(rawValue: 0xE6)
    static let rightGUI     = HIDKeyCode(rawValue: 0xE7)
}

// MARK: - Side determination

extension HIDKeyCode {

    private static let leftCodes: Set<Int> = [
        // Letters
        0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, // A-G
        0x14, 0x15, 0x16, 0x17, 0x19, 0x1A, 0x1B, 0x1D, // Q,R,S,T,V,W,X,Z
        // Numbers
        0x1E, 0x1F, 0x20, 0x21, 0x22, // 1-5
        // Symbols
        0x35, // ` (grave accent)
        // Special
        0x2B, // Tab
        0x29, // Escape
        0x39, // Caps Lock
        // Function keys
        0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, // F1-F6
        // Left modifiers
        0xE0, 0xE1, 0xE2, 0xE3, // LCtrl, LShift, LAlt, LGUI
        // ISO
        0x64, // Non-US Backslash (Section key)
        // JIS
        0x89, // International3 (¥)
        0x91, // LANG2 (英数)
    ]

    private static let rightCodes: Set<Int> = [
        // Letters
        0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x18, 0x1C, // H-P,U,Y
        // Punctuation
        0x33, 0x34, 0x36, 0x37, 0x38, // ;, ', comma, period, /
        // Numbers & symbols
        0x23, 0x24, 0x25, 0x26, 0x27, // 6-0
        0x2D, 0x2E, 0x2F, 0x30, 0x31, // -, =, [, ], backslash
        // Command
        0x28, // Return
        0x2A, // Backspace
        // Function keys
        0x40, 0x41, 0x42, 0x43, 0x44, 0x45, // F7-F12
        // Right modifiers
        0xE4, 0xE5, 0xE6, 0xE7, // RCtrl, RShift, RAlt, RGUI
        // Arrows
        0x4F, 0x50, 0x51, 0x52, // Right, Left, Down, Up
        // Navigation
        0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, // Insert, Home, PgUp, DelFwd, End, PgDn
        // All keypad
        0x53, 0x54, 0x55, 0x56, 0x57, 0x58, // NumLock, /, *, -, +, Enter
        0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F, 0x60, 0x61, 0x62, 0x63, 0x67, // 1-9, 0, ., =
        // JIS
        0x87, // International1 (ろ)
        0x90, // LANG1 (かな)
    ]

    var side: KeySide {
        if rawValue == 0x2C { // Spacebar
            return .both
        } else if Self.leftCodes.contains(rawValue) {
            return .left
        } else if Self.rightCodes.contains(rawValue) {
            return .right
        } else {
            return .none
        }
    }
}
