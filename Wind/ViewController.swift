//
//  ViewController.swift
//  Wind
//
//  Created by Егор on 5/7/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var qualityLevelLabel: NSTextField!
    @IBOutlet var statusImageView: NSImageView!
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var windowSelectorView: NSPopUpButton!
    @IBOutlet var timerLabel: NSTextField!
    @IBOutlet var directoryTextField: NSTextField!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var fpsTextField: NSTextField!
    @IBOutlet var imageScaleLabel: NSTextField!
    @IBOutlet var statusLabel: NSTextField!

    private var windowDict = [String: UInt32]()
    private var isRecording: Bool = false
    private var timer: Timer!
    private var capturingTimer: Timer!
    private var selectedWindowId: UInt32!
    private var gifMaker: GifMaker!
    private var path: NSURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]) {
        didSet {
            self.directoryTextField.stringValue = self.path.path ?? "Directory"
        }
    }

    private var imageQuality: Float = 100.0 {
        didSet {
            if imageQuality == 100.0 {
                qualityLevelLabel.stringValue = "Best"
            } else if imageQuality == 75.0 {
                qualityLevelLabel.stringValue = "High"
            } else if imageQuality == 50.0 {
                qualityLevelLabel.stringValue = "Medium"
            } else if imageQuality == 25.0 {
                qualityLevelLabel.stringValue = "Low"
            } else if imageQuality == 0 {
                qualityLevelLabel.stringValue = "Lowest"
            }
        }
    }

    private var counter = 0 {
        didSet {
            if counter < 60 {
                timerLabel.stringValue = "\(counter)" + " sec"
            } else {
                timerLabel.stringValue = "\(counter / 60):" + "\(counter % 60)"
            }
        }
    }

    private var imageScale: Float = 100 {
        didSet {
            self.imageScaleLabel.stringValue = String(imageScale.rounded()) + "%"
        }
    }

    override func viewDidAppear() {
        view.window?.styleMask.remove(NSWindow.StyleMask.resizable)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        windowSelectorView.removeAllItems()
        windowSelectorView.action = #selector(windowSelected(_:))
        updateWindows()
        windowSelectorView.setTitle("Select window")
        imageView.image = NSImage(cgImage: CGDisplayCreateImage(CGMainDisplayID())!, size: imageView.frame.size)
    }

    @IBAction func qualityChanged(_ sender: NSSlider) {
        imageQuality = sender.floatValue
    }

    @IBAction func scaleChanged(_ sender: NSSlider) {
        imageScale = sender.floatValue
    }

    @IBAction func recordButtonPressed(_ sender: NSButton) {
        // Checking if window is selected
        if selectedWindowId == nil {
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
        } else {
            sender.title = "Stop"
            isRecording = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            startCapturing()
        }
    }

    @IBAction func chooseDirectoryButtonPressed(_: NSButton) {
        let myPanel: NSOpenPanel = NSOpenPanel()
        myPanel.allowsMultipleSelection = false
        myPanel.canChooseDirectories = true
        myPanel.canChooseFiles = false
        myPanel.runModal()
        path = myPanel.urls[0] as NSURL
    }

    @IBAction func refreshWindows(_: NSButton) {
        updateWindows()
        updateSelectedWindowImageView()
    }

    @objc private func windowSelected(_: NSPopUpButton) {
        updateSelectedWindowImageView()
        windowSelectorView.setTitle(windowSelectorView.titleOfSelectedItem!)
        selectedWindowId = windowDict[windowSelectorView.titleOfSelectedItem!]!
    }

    func updateWindows() {
        guard let newWindows = WindowManager.windows() else { return }
        windowDict.removeAll()
        windowSelectorView.removeAllItems()
        newWindows.forEach { key, value in
            windowDict[key] = value
            self.windowSelectorView.addItem(withTitle: key)
        }
    }

    private func updateSelectedWindowImageView() {
        guard windowSelectorView.selectedItem != nil,
            let windowId = windowDict[windowSelectorView.titleOfSelectedItem!],
            let image = WindowManager.imageForWindowWith(windowId: windowId, size: imageView.frame.size)
        else {
            return
        }
        imageView.image = image
    }

    @objc private func timerAction() {
        counter += 1
    }

    private func startCapturing() {
        // Checking fps
        var fps = Float(fpsTextField.stringValue) ?? 10
        if fps <= 0 {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.informativeText = "FPS value is invalid"
            alert.messageText = "Choose FPS greater than 0"
            alert.runModal()
            return
        }
        fps = fps > 30 ? 30 : fps
        // Changing label and image status
        statusLabel.stringValue = "Recording"
        statusImageView.image = NSImage(named: NSImage.Name(rawValue: "NSStatusUnavailable"))
        var name = nameTextField.stringValue
        if name.isEmpty {
            name = "gif"
        }
        let pathLocal = NSURL(string: path.absoluteString! + name + ".gif")!
        gifMaker = GifMaker(quality: imageQuality, scale: imageScale, fps: fps, path: pathLocal)
        capturingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1 / fps), repeats: true, block: {
            _ in
            guard let image = CGWindowListCreateImage(CGRect.null, CGWindowListOption.optionIncludingWindow, self.selectedWindowId, CGWindowImageOption.boundsIgnoreFraming) else {
                return
            }
            self.gifMaker.addImageIntoGif(image: image)
            self.imageView.image = NSImage(cgImage: image, size: NSSize(width: self.imageView.frame.width, height: self.imageView.frame.height))
        })
    }

    private func stopCapturing() {
        statusLabel.stringValue = "Ready"
        statusImageView.image = NSImage(named: NSImage.Name(rawValue: "NSStatusAvailable"))
        capturingTimer.invalidate()
        gifMaker.generateGif(success: { success in
            if success {
                print("Done")
            } else {
                print("Fail")
            }
        })
        gifMaker = nil
    }
}
