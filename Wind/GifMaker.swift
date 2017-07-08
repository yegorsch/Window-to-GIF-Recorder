//
//  GifMaker.swift
//  Wind
//
//  Created by Егор on 5/9/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import Foundation
import ImageIO
import AppKit
class GifMaker{
    private var images:[CGImage]!
    private var quality:Float
    private var scale:Float
    private var fps:Float
    private var path:NSURL
    private var processingQueue:DispatchQueue!
    
    init(quality: Float,scale:Float, fps:Float, path:NSURL) {
        self.quality = quality / 100
        self.scale = scale / 100
        self.fps = fps
        self.path = path
        self.images = [CGImage]()
        processingQueue = DispatchQueue(label: "processingQ", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: self.processingQueue)
    }
    func addImageIntoGif(image:CGImage){
        processingQueue.async {
            self.images.append(image.resizeImage(level: self.quality, scale: self.scale))
        }
    }
    
    
    func generateGif(){
        
        if (self.images?.count)! > 0 {
            guard let destinationGIF = CGImageDestinationCreateWithURL(self.path, kUTTypeGIF, self.images.count, nil) else {
                print("lil")
                return
            }
            
            let gifProperties:[String:Any] = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String:self.fps ], kCGImagePropertyGIFHasGlobalColorMap as String : false]
            DispatchQueue.global(qos: .background).async {
                for img in self.images {
                    // Add the frame to the GIF image
                    CGImageDestinationAddImage(destinationGIF,  img, gifProperties as CFDictionary)
                }
                // Write the GIF file to disk
                if CGImageDestinationFinalize(destinationGIF){
                    print("HI")
                }
            }
        }
    }
    
    
}

