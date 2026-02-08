//
//  ToroAlertsMenuExtraTests.swift
//  ToroAlertsMenuExtraTests
//
//  Created by digdog on 2/6/26.
//

import Testing
@testable import ToroAlertsMenuExtra
import ToroAlerts

// MARK: - HIDKeyCode Side Tests

struct HIDKeyCodeSideTests {

    @Test func leftLettersReturnLeft() {
        let leftLetters: [HIDKeyCode] = [.keyA, .keyB, .keyC, .keyD, .keyE, .keyF, .keyG]
        for key in leftLetters {
            #expect(key.side == .left, "Expected \(key.rawValue) to be .left")
        }
    }

    @Test func leftRowTwoLettersReturnLeft() {
        let keys: [HIDKeyCode] = [.keyQ, .keyR, .keyS, .keyT, .keyV, .keyW, .keyX, .keyZ]
        for key in keys {
            #expect(key.side == .left, "Expected \(key.rawValue) to be .left")
        }
    }

    @Test func leftNumbersReturnLeft() {
        let keys: [HIDKeyCode] = [.one, .two, .three, .four, .five]
        for key in keys {
            #expect(key.side == .left, "Expected \(key.rawValue) to be .left")
        }
    }

    @Test func leftModifiersReturnLeft() {
        let keys: [HIDKeyCode] = [.leftControl, .leftShift, .leftAlt, .leftGUI]
        for key in keys {
            #expect(key.side == .left, "Expected \(key.rawValue) to be .left")
        }
    }

    @Test func leftSpecialKeysReturnLeft() {
        let keys: [HIDKeyCode] = [.tab, .escape, .capsLock, .graveAccentAndTilde]
        for key in keys {
            #expect(key.side == .left, "Expected \(key.rawValue) to be .left")
        }
    }

    @Test func leftFunctionKeysReturnLeft() {
        let keys: [HIDKeyCode] = [.F1, .F2, .F3, .F4, .F5, .F6]
        for key in keys {
            #expect(key.side == .left, "Expected \(key.rawValue) to be .left")
        }
    }

    @Test func rightLettersReturnRight() {
        let keys: [HIDKeyCode] = [.keyH, .keyI, .keyJ, .keyK, .keyL, .keyM, .keyN, .keyO, .keyP, .keyU, .keyY]
        for key in keys {
            #expect(key.side == .right, "Expected \(key.rawValue) to be .right")
        }
    }

    @Test func rightNumbersReturnRight() {
        let keys: [HIDKeyCode] = [.six, .seven, .eight, .nine, .zero]
        for key in keys {
            #expect(key.side == .right, "Expected \(key.rawValue) to be .right")
        }
    }

    @Test func rightModifiersReturnRight() {
        let keys: [HIDKeyCode] = [.rightControl, .rightShift, .rightAlt, .rightGUI]
        for key in keys {
            #expect(key.side == .right, "Expected \(key.rawValue) to be .right")
        }
    }

    @Test func rightPunctuationReturnRight() {
        let keys: [HIDKeyCode] = [.semicolon, .quote, .comma, .period, .slash,
                                   .hyphen, .equalSign, .openBracket, .closeBracket, .backslash]
        for key in keys {
            #expect(key.side == .right, "Expected \(key.rawValue) to be .right")
        }
    }

    @Test func rightCommandKeysReturnRight() {
        let keys: [HIDKeyCode] = [.returnOrEnter, .deleteOrBackspace]
        for key in keys {
            #expect(key.side == .right, "Expected \(key.rawValue) to be .right")
        }
    }

    @Test func rightFunctionKeysReturnRight() {
        let keys: [HIDKeyCode] = [.F7, .F8, .F9, .F10, .F11, .F12]
        for key in keys {
            #expect(key.side == .right, "Expected \(key.rawValue) to be .right")
        }
    }

    @Test func arrowKeysReturnRight() {
        let keys: [HIDKeyCode] = [.rightArrow, .leftArrow, .downArrow, .upArrow]
        for key in keys {
            #expect(key.side == .right, "Expected \(key.rawValue) to be .right")
        }
    }

    @Test func keypadKeysReturnRight() {
        let keys: [HIDKeyCode] = [.keypadNumLock, .keypadSlash, .keypadAsterisk,
                                   .keypad0, .keypad1, .keypad5, .keypad9, .keypadEnter, .keypadPeriod]
        for key in keys {
            #expect(key.side == .right, "Expected \(key.rawValue) to be .right")
        }
    }

    @Test func spacebarReturnsBoth() {
        #expect(HIDKeyCode.spacebar.side == .both)
    }

    @Test func unmappedKeyReturnsNone() {
        // 0x46 = PrintScreen, not in left or right sets
        let unmapped = HIDKeyCode(rawValue: 0x46)
        #expect(unmapped.side == .none)
    }

    @Test func jisKeysMapCorrectly() {
        #expect(HIDKeyCode.international3.side == .left)   // ¥
        #expect(HIDKeyCode.lang2.side == .left)            // 英数
        #expect(HIDKeyCode.international1.side == .right)  // ろ
        #expect(HIDKeyCode.lang1.side == .right)           // かな
    }

    @Test func isoKeyMapsLeft() {
        #expect(HIDKeyCode.nonUSBackslash.side == .left)
    }
}

// MARK: - KeyEventMapper Tests

struct KeyEventMapperTests {

    @Test func singleLeftPress() {
        var mapper = KeyEventMapper()
        let result = mapper.map(side: .left, typingInterval: nil)
        #expect(result != nil)
        #expect(result?.request == .left)
        #expect(result?.interval == .milliseconds(500)) // default interval
    }

    @Test func singleRightPress() {
        var mapper = KeyEventMapper()
        let result = mapper.map(side: .right, typingInterval: nil)
        #expect(result != nil)
        #expect(result?.request == .right)
    }

    @Test func singleBothPress() {
        var mapper = KeyEventMapper()
        let result = mapper.map(side: .both, typingInterval: nil)
        #expect(result != nil)
        #expect(result?.request == .both)
    }

    @Test func noneSideReturnsNil() {
        var mapper = KeyEventMapper()
        let result = mapper.map(side: .none, typingInterval: nil)
        #expect(result == nil)
    }

    @Test func tripleRightProducesRightTriple() {
        var mapper = KeyEventMapper()
        _ = mapper.map(side: .right, typingInterval: nil)
        _ = mapper.map(side: .right, typingInterval: .milliseconds(100))
        let result = mapper.map(side: .right, typingInterval: .milliseconds(100))
        #expect(result?.request == .rightTriple)
    }

    @Test func tripleBothProducesBothTriple() {
        var mapper = KeyEventMapper()
        _ = mapper.map(side: .both, typingInterval: nil)
        _ = mapper.map(side: .both, typingInterval: .milliseconds(100))
        let result = mapper.map(side: .both, typingInterval: .milliseconds(100))
        #expect(result?.request == .bothTriple)
    }

    @Test func quadBothProducesBothQuad() {
        var mapper = KeyEventMapper()
        _ = mapper.map(side: .both, typingInterval: nil)
        _ = mapper.map(side: .both, typingInterval: .milliseconds(100))
        _ = mapper.map(side: .both, typingInterval: .milliseconds(100))
        let result = mapper.map(side: .both, typingInterval: .milliseconds(100))
        #expect(result?.request == .bothQuad)
    }

    @Test func alternatingLRLRProducesLrlrlr() {
        var mapper = KeyEventMapper()
        _ = mapper.map(side: .left, typingInterval: nil)
        _ = mapper.map(side: .right, typingInterval: .milliseconds(100))
        _ = mapper.map(side: .left, typingInterval: .milliseconds(100))
        let result = mapper.map(side: .right, typingInterval: .milliseconds(100))
        // 4th press completes alternatingCount >= triggerCount, last side is .right → .rlrlrl
        #expect(result?.request == .rlrlrl)
    }

    @Test func alternatingRLRLProducesRlrlrl() {
        var mapper = KeyEventMapper()
        _ = mapper.map(side: .right, typingInterval: nil)
        _ = mapper.map(side: .left, typingInterval: .milliseconds(100))
        _ = mapper.map(side: .right, typingInterval: .milliseconds(100))
        let result = mapper.map(side: .left, typingInterval: .milliseconds(100))
        // 4th press completes alternatingCount >= triggerCount, last side is .left → .lrlrlr
        #expect(result?.request == .lrlrlr)
    }

    @Test func intervalClampedToFloor() {
        var mapper = KeyEventMapper()
        let result = mapper.map(side: .left, typingInterval: .milliseconds(10))
        #expect(result != nil)
        #expect(result?.interval == .milliseconds(50))
    }

    @Test func intervalClampedToCeiling() {
        var mapper = KeyEventMapper()
        let result = mapper.map(side: .left, typingInterval: .milliseconds(2000))
        #expect(result != nil)
        #expect(result?.interval == .milliseconds(1000))
    }

    @Test func intervalPassthroughInRange() {
        var mapper = KeyEventMapper()
        let result = mapper.map(side: .left, typingInterval: .milliseconds(200))
        #expect(result != nil)
        #expect(result?.interval == .milliseconds(200))
    }

    @Test func consecutiveResetOnSideChange() {
        var mapper = KeyEventMapper()
        _ = mapper.map(side: .right, typingInterval: nil)
        _ = mapper.map(side: .right, typingInterval: .milliseconds(100))
        // Switch to left, resets consecutive count
        _ = mapper.map(side: .left, typingInterval: .milliseconds(100))
        // Back to right, only 1 consecutive
        let result = mapper.map(side: .right, typingInterval: .milliseconds(100))
        #expect(result?.request == .right)
    }

    @Test func tripleLeftDoesNotTriggerSpecialRequest() {
        // Left has no triple pattern defined
        var mapper = KeyEventMapper()
        _ = mapper.map(side: .left, typingInterval: nil)
        _ = mapper.map(side: .left, typingInterval: .milliseconds(100))
        let result = mapper.map(side: .left, typingInterval: .milliseconds(100))
        #expect(result?.request == .left)
    }
}

// MARK: - DeviceRequest Extension Tests

struct DeviceRequestExtensionTests {

    @Test func singlePressRequestsAreNotMultiPress() {
        #expect(!DeviceRequest.left.isMultiPress)
        #expect(!DeviceRequest.right.isMultiPress)
        #expect(!DeviceRequest.both.isMultiPress)
        #expect(!DeviceRequest.noop.isMultiPress)
    }

    @Test func multiPressRequestsAreMultiPress() {
        #expect(DeviceRequest.rightTriple.isMultiPress)
        #expect(DeviceRequest.bothTriple.isMultiPress)
        #expect(DeviceRequest.bothQuad.isMultiPress)
        #expect(DeviceRequest.lrlrlr.isMultiPress)
        #expect(DeviceRequest.rlrlrl.isMultiPress)
    }

    @Test func movementCounts() {
        #expect(DeviceRequest.noop.movementCount == 0)
        #expect(DeviceRequest.left.movementCount == 1)
        #expect(DeviceRequest.right.movementCount == 1)
        #expect(DeviceRequest.both.movementCount == 1)
        #expect(DeviceRequest.rl.movementCount == 2)
        #expect(DeviceRequest.rightTriple.movementCount == 3)
        #expect(DeviceRequest.bothTriple.movementCount == 3)
        #expect(DeviceRequest.bothQuad.movementCount == 4)
        #expect(DeviceRequest.lrlrlr.movementCount == 6)
        #expect(DeviceRequest.rlrlrl.movementCount == 6)
    }
}
