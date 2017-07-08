//
//  ViewController.swift
//  Wind
//
//  Created by Егор on 5/7/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {

    @IBOutlet weak var qualityLevelLabel: NSTextField!
    @IBOutlet weak var statusImageView: NSImageView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var windowSelectorView: NSPopUpButton!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var directoryTextField: NSTextField!
    @IBOutlet weak var nameTextField: NSTextField!

    @IBOutlet weak var fpsTextField: NSTextField!
    
    private var windowDict = [String : UInt32]()
    private var path:NSURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]) { didSet { self.directoryTextField.stringValue = self.path.path ?? "Directory" } }
    private var isRecording:Bool = false
    private var timer:Timer!
    private var counter = 0 { didSet {
        if (counter < 60){
            timerLabel.stringValue = "\(counter)" + " sec"
        }else{
            timerLabel.stringValue = "\(counter / 60):" + "\(counter % 60)"
        }
        }}
    private var capturingTimer:Timer!
    private var selectedWindowId:UInt32!
    private var gifMaker:GifMaker!
    private var imageQuality:Float = 100.0 { didSet{
        if imageQuality == 100.0{
            qualityLevelLabel.stringValue = "Best"
        }else if imageQuality == 75.0{
            qualityLevelLabel.stringValue = "High"
        }else if imageQuality == 50.0{
            qualityLevelLabel.stringValue = "Medium"
        }else if imageQuality == 25.0{
            qualityLevelLabel.stringValue = "Low"
        }else if imageQuality == 0{
            qualityLevelLabel.stringValue = "Lowest"
        }
        }
    }
    @IBOutlet weak var imageScaleLabel: NSTextField!
    private var imageScale:Float = 100 { didSet{
        self.imageScaleLabel.stringValue = String(imageScale.rounded()) + "%"
        }}
    @IBOutlet weak var statusLabel: NSTextField!
    
    
    override func viewDidAppear() {
        self.view.window?.styleMask.remove(NSWindowStyleMask.resizable)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        windowSelectorView.removeAllItems()
        windowSelectorView.action = #selector(windowSelected(_:))
        getWindows()
        windowSelectorView.setTitle("Select window")
        self.imageView.image = NSImage(cgImage: CGDisplayCreateImage(CGMainDisplayID())!, size: imageView.frame.size)
    }
    
    @IBAction func qualityChanged(_ sender: NSSlider) {
        self.imageQuality = sender.floatValue
    }

    @IBAction func scaleChanged(_ sender: NSSlider) {
        self.imageScale = sender.floatValue
    }
    
    func windowSelected(_ sender: NSPopUpButton){
        let image = CGWindowListCreateImage(CGRect.null, CGWindowListOption.optionIncludingWindow,      windowDict[windowSelectorView.titleOfSelectedItem!]!               ,CGWindowImageOption.boundsIgnoreFraming)
        self.imageView.image = NSImage(cgImage: image!, size: self.imageView.frame.size)
         self.windowSelectorView.setTitle(windowSelectorView.titleOfSelectedItem!)
        self.selectedWindowId = windowDict[windowSelectorView.titleOfSelectedItem!]!
    }
    func getWindows(){
        windowDict.removeAll()
        windowSelectorView.removeAllItems()
        if let windows = CGWindowListCopyWindowInfo(CGWindowListOption.optionOnScreenAboveWindow, kCGNullWindowID) as? [[String : Any]]{
            for window in windows{
                windowDict[(window["kCGWindowOwnerName"] as? String)!] = window["kCGWindowNumber"] as? UInt32
                windowSelectorView.addItem(withTitle: (window["kCGWindowOwnerName"] as? String)!)
                
            }
        }
    }
    

    @IBAction func refreshWindows(_ sender: NSButton) {
        getWindows()
        if windowSelectorView.selectedItem == nil{
            return
        }
        let windowId = windowDict[windowSelectorView.titleOfSelectedItem!  ]
        let image = CGWindowListCreateImage(CGRect.null, CGWindowListOption.optionIncludingWindow,  windowId! ,CGWindowImageOption.boundsIgnoreFraming)
        self.imageView.image = NSImage(cgImage: image!, size: self.imageView.frame.size)
    }
    
    @IBAction func chooseDirectoryButtonPressed(_ sender: NSButton) {
        let myPanel:NSOpenPanel = NSOpenPanel()
        myPanel.allowsMultipleSelection = false
        myPanel.canChooseDirectories = true
        myPanel.canChooseFiles = false
        myPanel.runModal()
        self.path =  (myPanel.urls[0] as? NSURL)!
    }

    @IBAction func recordButtonPressed(_ sender: NSButton) {
        //Checking if window is selected
        if self.selectedWindowId == nil{
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.informativeText = "You need to select the window"
            alert.messageText = "No window selected"
            alert.runModal()
            return
        }

        if isRecording {
            sender.title = "Record"
            isRecording = false
            timer.invalidate()
            counter = 0
            timerLabel.stringValue = "00:00"
            stopCapturing()
        }else{
            sender.title = "Stop"
            isRecording = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            startCapturing()
            
        }
    }
    @objc private func timerAction(){
        counter += 1;
    }
    private func startCapturing(){
        // Checking fps
        var fps = Float(self.fpsTextField.stringValue) ?? 10
        if  fps == 0 {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.informativeText = "FPS value is invalid"
            alert.messageText = "Choose FPS greater than 0"
            alert.runModal()
            return
        }
        if fps > 30{
            fps = 30
        }
        // Changing label and image status
        self.statusLabel.stringValue = "Recording"
        self.statusImageView.image = NSImage(named: "NSStatusUnavailable")
        var name = nameTextField.stringValue
        if (name.isEmpty) {
            name = "gif"
        }
        let pathLocal = NSURL(string: self.path.absoluteString! + "/" + name + ".gif")!
        gifMaker = GifMaker(quality: self.imageQuality, scale: self.imageScale, fps: fps, path: pathLocal)
        capturingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1 / fps) , repeats: true, block: {
            timer in
        let image = CGWindowListCreateImage(CGRect.null, CGWindowListOption.optionIncludingWindow,      self.selectedWindowId ,CGWindowImageOption.boundsIgnoreFraming)
            self.gifMaker.addImageIntoGif(image: image!)
            self.imageView.image = NSImage(cgImage: image!, size: NSSize(width: self.imageView.frame.width, height: self.imageView.frame.height))
        })
    }
    private func stopCapturing(){
        self.statusLabel.stringValue = "Ready"
        self.statusImageView.image = NSImage(named: "NSStatusAvailable")
        capturingTimer.invalidate()
        gifMaker.generateGif()
    }
    


}

