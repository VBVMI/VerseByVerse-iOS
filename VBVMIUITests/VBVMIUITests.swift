//
//  VBVMIUITests.swift
//  VBVMIUITests
//
//  Created by Thomas Carey on 17/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import XCTest

class VBVMIUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTakeScreenshots() {
        
//        let app = XCUIApplication()
        sleep(4)
        snapshot("0Studies", waitForLoadingIndicator: true)
        
        XCUIApplication().collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        sleep(2)
        snapshot("0Study", waitForLoadingIndicator: true)
    }
    
    
}
