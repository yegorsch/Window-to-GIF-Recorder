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
    private var fps:Double
    private var path:NSURL
    private var processingQueue:DispatchQueue!
    
    init(quality: Float,scale:Float, fps:Double, path:NSURL) {
        self.quality = quality / 100
        self.scale = scale / 100
        self.fps = fps
        self.path = path
        self.images = [CGImage]()
        processingQueue = DispatchQueue(label: "processingQ")
    }
    func addImageIntoGif(image:CGImage){
       self.images.append(image)
    }
    
    func generateGif(){

        if (self.images?.count)! > 0 {

            guard let destinationGIF = CGImageDestinationCreateWithURL(self.path, kUTTypeGIF, self.images.count, nil) else {
                print("lil")
                return
            }
            
            let properties = [
                (kCGImagePropertyGIFDictionary as String): [(kCGImagePropertyGIFDelayTime as String): 1 / self.fps]
            ]
            DispatchQueue.global().async {
            autoreleasepool(invoking: {
            for img in self.images {
                // Add the frame to the GIF image
                    // code
                CGImageDestinationAddImage(destinationGIF,  img.resizeImage(level: self.quality, scale: self.scale), properties as CFDictionary)
            }
            })
            }
            // Write the GIF file to disk
            CGImageDestinationFinalize(destinationGIF)
        

            
        }
    }


}

