//
//  GifMaker.swift
//  Wind
//
//  Created by Егор on 5/9/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import AppKit
import Foundation
import ImageIO

class GifMaker {
    private var images: [CGImage]!
    private var quality: Float
    private var scale: Float
    private var fps: Float
    private var path: NSURL
    private var processingQueue: DispatchQueue!
    private var dispatchGroup: DispatchGroup!
    private var destinationGIF: CGImageDestination!
    private var success = false
    private var initTime = Date()
    typealias SuccessBlock = (Bool) -> Void
    typealias ProgressPercentBlock = (Double) -> Void

    let fileProperties: CFDictionary
    var frameProperties: CFDictionary

    init(quality: Float, scale: Float, fps: Float, path: NSURL) {
        self.quality = quality / 100
        self.scale = scale / 100
        self.fps = fps
        self.path = path
        images = [CGImage]()
        processingQueue = DispatchQueue(label: "processingQ",
                                        qos: .background,
                                        attributes: .concurrent,
                                        autoreleaseFrequency: .workItem,
                                        target: processingQueue)
        dispatchGroup = DispatchGroup()
        frameProperties = [
            kCGImagePropertyGIFDictionary as String:
                [(kCGImagePropertyGIFDelayTime as String): 1 / self.fps],
        ] as CFDictionary
        fileProperties = [
            kCGImagePropertyGIFDictionary as String:
                [kCGImagePropertyGIFLoopCount as String: 0],
        ] as CFDictionary
    }

    func addImageIntoGif(image: CGImage) {
        processingQueue.sync {
            let resizedImage = image.resizeImage(level: self.quality, scale: self.scale)
            images.append(resizedImage)
        }
    }

    func generateGif(progress: @escaping ProgressPercentBlock, success: @escaping SuccessBlock) {
        // Creating GIF with properties
        destinationGIF = CGImageDestinationCreateWithURL(path, kUTTypeGIF, images.count, nil)
        CGImageDestinationSetProperties(destinationGIF, fileProperties)
        processingQueue.async(group: dispatchGroup, qos: .background, flags: .enforceQoS, execute: { [weak self] in
            guard let self = self else { return }
            self.images.reverse()
            let initialNumberOfImages = Double(self.images.count)
            while self.images.count > 0 {
                let image = self.images.popLast()!
                let percent: Double = 1 - Double(self.images.count) / initialNumberOfImages
                DispatchQueue.main.async {
                    progress(percent * 100.0)
                }
                CGImageDestinationAddImage(self.destinationGIF, image, self.frameProperties)
            }
            self.success = CGImageDestinationFinalize(self.destinationGIF)
        })
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            success(self.success)
        })
    }
}
