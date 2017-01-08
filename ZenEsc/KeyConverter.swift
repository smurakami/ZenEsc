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
        // うまくアプリケーション間のフォーカスが動かないことの対策。
//        print("set active app")
//        let app = notification.userInfo!["NSWorkspaceApplicationKey"] as! NSRunningApplication
//        
//        if let name = app.localizedName, let id = app.bundleIdentifier {
//            print(name)
//            print(id)
//        }
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

        if (type == .flagsChanged && keyCode == 59) {
            if event.flags.contains(CGEventFlags.maskControl) {
                toSendESC = true
            } else {
                if toSendESC {
                    let loc = CGEventTapLocation.cghidEventTap
                    let eisuuEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(102), keyDown: true)!
                    eisuuEvent.flags = []
                    eisuuEvent.post(tap: loc)
//
                    event.setIntegerValueField(.keyboardEventKeycode, value: 53)
                    event.type = .keyDown
                    return Unmanaged.passUnretained(event)
                }
            }
        } else {
            toSendESC = false
        }
        
        return Unmanaged.passUnretained(event)
        
//        if let mediaKeyEvent = MediaKeyEvent(event) {
//            return mediaKeyEvent.keyDown ? mediaKeyDown(mediaKeyEvent) : mediaKeyUp(mediaKeyEvent)
//        }
//        
//        switch type {
//        case CGEventType.flagsChanged:
//            let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
//            let flags = event.flags
//            print(flags.contains(CGEventFlags.maskControl))
//            return Unmanaged.passUnretained(event)
//            
//            //
//            //            if modifierMasks[keyCode] == nil {
//            //                return Unmanaged.passUnretained(event)
//            //            }
//            //            return event.flags.rawValue & modifierMasks[keyCode]!.rawValue != 0 ?
//            //                modifierKeyDown(event) : modifierKeyUp(event)
//        //
//        case CGEventType.keyDown:
//            return keyDown(event)
//            
//        case CGEventType.keyUp:
//            return keyUp(event)
//            
//        default:
//            self.keyCode = nil
//            
//            return Unmanaged.passUnretained(event)
//        }
    }

    func keyDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
//        #if DEBUG
//            // print("keyCode: \(KeyboardShortcut(event).keyCode)")
//             print(KeyboardShortcut(event).toString())
//        #endif
        
        
        self.keyCode = nil
        
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
//        print(event)
//        print(keyCode)
        
//        if let keyTextField = activeKeyTextField {
//            keyTextField.shortcut = KeyboardShortcut(event)
//            keyTextField.stringValue = keyTextField.shortcut!.toString()
//            
//            return nil
//        }
        
//        if hasConvertedEvent(event) {
//            if let event = getConvertedEvent(event) {
//                return Unmanaged.passUnretained(event)
//            }
//            return nil
//        }
        
        return Unmanaged.passUnretained(event)
    }
    
    func keyUp(_ event: CGEvent) -> Unmanaged<CGEvent>? {
//        print(event)
//        self.keyCode = nil
//        
//        if hasConvertedEvent(event) {
//            if let event = getConvertedEvent(event) {
//                return Unmanaged.passUnretained(event)
//            }
//            return nil
//        }
        
        return Unmanaged.passUnretained(event)
    }
}
