//
//  BGReadingTests.swift
//  BGCompass
//
//  Created by Steve Baker on 1/7/17.
//  Copyright © 2017 Clif Alferness. All rights reserved.
//

import XCTest
@testable import BGCompass

class BGReadingTests: XCTestCase {
    
    // test we can use convenience method from Swift
    func testBGReading() {
        let name = "foo"
        let timeStamp = Date()
        // BGReading.quantity units mmol/L
        let quantity = (123 / MG_PER_DL_PER_MMOL_PER_L) as NSNumber
        let isPending = false
        let bgReading = BGReadingTestHelper.bgReading(withName: name,
                                                      timeStamp: timeStamp,
                                                      quantity: quantity,
                                                      isPending: isPending)
        XCTAssertEqual(bgReading!.name, name)
        XCTAssertEqual(bgReading!.timeStamp, timeStamp)
        XCTAssertEqual(bgReading!.quantity, quantity)
        XCTAssertEqual(bgReading!.isPending.boolValue, isPending)
    }


}
