//
//  GifProcessingOperation.swift
//  Wind
//
//  Created by Егор on 3/10/18.
//  Copyright © 2018 Yegor's Mac. All rights reserved.
//

import AppKit
import Cocoa
import Foundation
import ImageIO

class GifProcessingOperation: Operation {
    private var path: NSURL
    private var images: [CGImage]

    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }

    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }

    enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + rawValue }
    }

    init(path: NSURL, images: [CGImage]) {
        self.path = path
        self.images = images
    }

    override func main() {
    }
}
