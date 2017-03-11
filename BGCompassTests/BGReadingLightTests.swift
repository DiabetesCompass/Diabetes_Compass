//
//  BGReadingLightTests.swift
//  BGCompass
//
//  Created by Steve Baker on 2/5/17.
//  Copyright © 2017 Clif Alferness. All rights reserved.
//

import XCTest
@testable import BGCompass

class BGReadingLightTests: XCTestCase {
    
    func testBGReadingLightInit() {
        let timeStamp = Date()
        let quantity = (123 / MG_PER_DL_PER_MMOL_PER_L)

        // method under test
        let bgReadingLight = BGReadingLight(timeStamp: timeStamp, quantity: quantity)

        XCTAssertEqual(bgReadingLight.timeStamp, timeStamp)
        XCTAssertEqual(bgReadingLight.quantity, quantity)
    }

    func testBGReadingLightInitWithBGReading() {
        let name = "foo"
        let timeStamp = Date()
        // BGReading.quantity units mmol/L
        let quantity = (123 / MG_PER_DL_PER_MMOL_PER_L) as NSNumber
        let isPending = false
        // use convenience method from Swift
        guard let bgReading = BGReadingTestHelper.bgReading(withName: name,
                                                            timeStamp: timeStamp,
                                                            quantity: quantity,
                                                            isPending: isPending)
            else {
                XCTFail("couldn't initialize a BGReading for use by BGReadingLight")
                return
        }

        // method under test
        let bgReadingLight = BGReadingLight(bgReading: bgReading)

        XCTAssertEqual(bgReadingLight.timeStamp, timeStamp)
        XCTAssertEqual(bgReadingLight.quantity, quantity.floatValue)
    }
}
