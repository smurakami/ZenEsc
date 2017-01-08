//
//  AppDelegate.swift
//  ZenEsc
//
//  Created by 村上晋太郎 on 2017/01/08.
//  Copyright © 2017年 村上晋太郎. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    var statusItem: NSStatusItem = NSStatusItem()
    var converter: KeyConverter?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        setupStatusBar()
        converter = KeyConverter()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func setupStatusBar() {
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        statusItem.title = "E"
        statusItem.highlightMode = true
        statusItem.menu = statusMenu
    }
}

