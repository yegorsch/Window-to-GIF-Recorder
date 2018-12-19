//
//  WindowManager.swift
//  Wind
//
//  Created by Егор on 8/1/18.
//  Copyright © 2018 Yegor's Mac. All rights reserved.
//

import AppKit
import Foundation

final class WindowManager {
    static func windows() -> [String: UInt32]? {
        guard let windows = CGWindowListCopyWindowInfo(CGWindowListOption.optionOnScreenAboveWindow, kCGNullWindowID) as? [[String: Any]] else {
            return nil
        }
        var windowsDict = [String: UInt32]()
        for window in windows {
            windowsDict[(window["kCGWindowOwnerName"] as? String)!] = window["kCGWindowNumber"] as? UInt32
        }
        return windowsDict
    }

    static func imageForWindowWith(windowId: UInt32, size: CGSize) -> NSImage? {
        guard let cgImage = CGWindowListCreateImage(CGRect.null, CGWindowListOption.optionIncludingWindow, windowId, CGWindowImageOption.boundsIgnoreFraming) else {
            return nil
        }
        let image = NSImage(cgImage: cgImage, size: size)
        return image
    }
}
