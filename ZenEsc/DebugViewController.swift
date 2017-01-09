//
//  ViewController.swift
//  ZenEsc
//
//  Created by 村上晋太郎 on 2017/01/08.
//  Copyright © 2017年 村上晋太郎. All rights reserved.
//

import Cocoa

var debugController: DebugViewController? = nil

class DebugViewController: NSViewController {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        textView.string = ""
    }
    
    override func viewWillAppear() {
        debugController = self
    }
    
    override func viewWillDisappear() {
        debugController = nil
    }
    
    func print(_ object: CustomStringConvertible) {
        let text = object.description
        
        textView.string = (textView.string ?? "") + text + "\n"
        textView.scrollRangeToVisible(NSRange(location: textView.string?.characters.count ?? 0, length: 0))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

