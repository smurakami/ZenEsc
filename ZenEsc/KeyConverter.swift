//
//  KeyConverter.swift
//  ZenEsc
//
//  Created by 村上晋太郎 on 2017/01/08.
//  Copyright © 2017年 村上晋太郎. All rights reserved.
//

import Cocoa

class KeyConverter: NSObject {
    
    var keyCode: CGKeyCode? = nil
    var toSendESC = false
    var currentAppId = ""
    
    override init() {
        super.init()
        
        NSWorkspace.shared().notificationCenter.addObserver(self,
                                                            selector: #selector(setActiveApp(_:)),
                                                            name: NSNotification.Name.NSWorkspaceDidActivateApplication,
                                                            object:nil)
        watch()
    }
    
    func setActiveApp(_ notification: NSNotification) {
        // do notiong
        let app = notification.userInfo!["NSWorkspaceApplicationKey"] as! NSRunningApplication
        
        if let id = app.bundleIdentifier {
            currentAppId = id
            print(id)
        }
    }
    
    func watch() {
        let eventMaskList = [
            CGEventType.keyDown.rawValue,
            CGEventType.keyUp.rawValue,
            CGEventType.flagsChanged.rawValue,
            CGEventType.leftMouseDown.rawValue,
            CGEventType.leftMouseUp.rawValue,
            CGEventType.rightMouseDown.rawValue,
            CGEventType.rightMouseUp.rawValue,
            CGEventType.otherMouseDown.rawValue,
            CGEventType.otherMouseUp.rawValue,
//            CGEventType.scrollWheel.rawValue,
            UInt32(NX_SYSDEFINED) // Media key Event
        ]
        
        var eventMask: UInt32 = 0
        
        for mask in eventMaskList {
            eventMask |= (1 << mask)
        }
        
        let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? in
                if let observer = refcon {
                    let mySelf = Unmanaged<KeyConverter>.fromOpaque(observer).takeUnretainedValue()
                    return mySelf.eventCallback(proxy: proxy, type: type, event: event)
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: observer
            ) else {
                print("failed to create event tap")
                exit(1)
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }

    
    func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        debugController?.print(keyCode)
        if currentAppId == "com.tinyspeck.slackmacgap" {
            return slack(type: type, event: event)
        }
        
        return common(type: type, event: event)
    }
    
    func sendEsc() {
        sendKeyDown(keyCode: 53)
        sendKeyUp(keyCode: 53)
    }
    
    func sendEisuu() {
        sendKeyDown(keyCode: 102)
        sendKeyUp(keyCode: 102)
    }
    
    func sendKeyDown(keyCode: CGKeyCode) {
        let loc = CGEventTapLocation.cghidEventTap
        let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)!
        event.flags = []
        event.post(tap: loc)
    }
    func sendKeyUp(keyCode: CGKeyCode) {
        let loc = CGEventTapLocation.cghidEventTap
        let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)!
        event.flags = CGEventFlags()
        event.post(tap: loc)
    }
}

extension KeyConverter {
    func common(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        
        if keyCode == 59 {
            if type == .flagsChanged {
                if event.flags.contains(CGEventFlags.maskControl) {
                    debugController?.print("esc prepare")
                    toSendESC = true
                } else {
                    if toSendESC {
                        debugController?.print("esc send!")
                        sendEisuu()
                        sendEsc()
                        toSendESC = false
                        return Unmanaged.passUnretained(event)
                    }
                }
            }
        } else {
            debugController?.print("esc cancel!")
            toSendESC = false
        }
        return Unmanaged.passUnretained(event)
    }
    
    func slack(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .keyDown {
            let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
            if keyCode == 36 { // return
                if event.flags.contains(.maskCommand) {
                    event.flags.remove(.maskCommand)
                } else if event.flags.contains(.maskShift) {
                    event.flags.remove(.maskShift)
                    event.flags.insert(.maskCommand)
                } else {
                    let masks: CGEventFlags = [
                        .maskCommand,
                        .maskShift,
                        .maskControl,
                        .maskAlternate,
                        ]
                    if !event.flags.contains(masks) {
                        // enter
                        event.flags.insert(.maskShift)
                    }
                
                    
                }
                
//                if event.flags.contains(.maskCommand) {
//                    event.flags = .maskShift
//                } else if event.flags.contains(.maskShift) {
//                    event.flags = .maskCommand
//                } else {
//                    
//                }
            }
        }
        
        return common(type: type, event: event)
    }
}

let keyCodeDictionary: Dictionary<CGKeyCode, String> = [
    0: "A",
    1: "S",
    2: "D",
    3: "F",
    4: "H",
    5: "G",
    6: "Z",
    7: "X",
    8: "C",
    9: "V",
    10: "DANISH_DOLLAR",
    11: "B",
    12: "Q",
    13: "W",
    14: "E",
    15: "R",
    16: "Y",
    17: "T",
    18: "1",
    19: "2",
    20: "3",
    21: "4",
    22: "6",
    23: "5",
    24: "=",
    25: "9",
    26: "7",
    27: "-",
    28: "8",
    29: "0",
    30: "]",
    31: "O",
    32: "U",
    33: "[",
    34: "I",
    35: "P",
    36: "⏎",
    37: "L",
    38: "J",
    39: "'",
    40: "K",
    41: ";",
    42: "\\",
    43: ",",
    44: "/",
    45: "N",
    46: "M",
    47: ".",
    48: "⇥",
    49: "Space",
    50: "`",
    51: "⌫",
    52: "Enter_POWERBOOK",
    53: "⎋",
    54: "Command_R",
    55: "Command_L",
    56: "Shift_L",
    57: "CapsLock",
    58: "Option_L",
    59: "Control_L",
    60: "Shift_R",
    61: "Option_R",
    62: "Control_R",
    63: "Fn",
    64: "F17",
    65: "Keypad_Dot",
    67: "Keypad_Multiply",
    69: "Keypad_Plus",
    71: "Keypad_Clear",
    75: "Keypad_Slash",
    76: "⌤",
    78: "Keypad_Minus",
    79: "F18",
    80: "F19",
    81: "Keypad_Equal",
    82: "Keypad_0",
    83: "Keypad_1",
    84: "Keypad_2",
    85: "Keypad_3",
    86: "Keypad_4",
    87: "Keypad_5",
    88: "Keypad_6",
    89: "Keypad_7",
    90: "F20",
    91: "Keypad_8",
    92: "Keypad_9",
    93: "¥",
    94: "_",
    95: "Keypad_Comma",
    96: "F5",
    97: "F6",
    98: "F7",
    99: "F3",
    100: "F8",
    101: "F9",
    102: "英数",
    103: "F11",
    104: "かな",
    105: "F13",
    106: "F16",
    107: "F14",
    109: "F10",
    110: "App",
    111: "F12",
    113: "F15",
    114: "Help",
    115: "Home", // "↖",
    116: "PgUp",
    117: "⌦",
    118: "F4",
    119: "End", // "↘",
    120: "F2",
    121: "PgDn",
    122: "F1",
    123: "←",
    124: "→",
    125: "↓",
    126: "↑",
    127: "PC_POWER",
    128: "GERMAN_PC_LESS_THAN",
    130: "DASHBOARD",
    131: "Launchpad",
    144: "BRIGHTNESS_UP",
    145: "BRIGHTNESS_DOWN",
    160: "Expose_All",
]


