//
//  CompressionExtension.swift
//  Wind
//
//  Created by Егор on 5/10/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import AppKit
import Foundation
import ImageIO

extension CGImage {
    func resizeImage(level: Float, scale: Float) -> CGImage {
        let bitmapRep = NSBitmapImageRep(cgImage: self)
        let jpegData = bitmapRep.representation(using: .jpeg, properties:
            [NSBitmapImageRep.PropertyKey.compressionFactor: level])
        let data = CGImageSourceCreateWithData(jpegData! as CFData, nil)
        // Checking the image orientation
        var maxSideLength = width
        if height > width {
            maxSideLength = height
        }
        maxSideLength = Int(Float(maxSideLength) * scale)
        let options: [String: Any] = [
            kCGImageSourceCreateThumbnailWithTransform as String: kCFBooleanTrue,
            kCGImageSourceCreateThumbnailFromImageAlways as String: kCFBooleanTrue,
            kCGImageSourceThumbnailMaxPixelSize as String: maxSideLength,
        ]
        return CGImageSourceCreateThumbnailAtIndex(data!, 0, options as CFDictionary)!
    }
}
