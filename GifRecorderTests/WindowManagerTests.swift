//
//  WindowManagerTests.swift
//  GifRecorderTests
//
//  Created by Егор on 8/1/18.
//  Copyright © 2018 Yegor's Mac. All rights reserved.
//

@testable import Wind
import XCTest

class WindowManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testWindows() {
        WindowManager.windows()
    }
}
