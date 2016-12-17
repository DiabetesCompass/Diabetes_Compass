//
//  TrendsViewControllerTests.swift
//  BGCompass
//
//  Created by Steve Baker on 12/10/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import XCTest
@testable import BGCompass

class TrendsViewControllerTests: XCTestCase {

    func testBloodGlucoseTextReadingNil() {
        XCTAssertEqual(TrendsViewController.bloodGlucoseText(reading: nil), "No data")
    }

    func testBloodGlucoseTextReading() {
        // Probably easier to test this from Objective C
        // Not sure how to do it in Swift.
        // https://www.andrewcbancroft.com/2015/01/13/unit-testing-model-layer-core-data-swift/
        // http://stackoverflow.com/questions/29313645/swift-coredata-unittest-how-to-avoid-exc-breakpoint
        // http://stackoverflow.com/questions/24662780/swift-cannot-test-core-data-in-xcode-tests/26795795#26795795
        // let context = NSManagedObjectContext.MR_newContext()
        // let bg = BGReading.MR_createEntity()
        // bg.name = "Blood Glucose"
        // bg.setQuantity(72,  withConversion: false)
        // bg.timeStamp = Date()
        // print("testBloodGlucoseTextReading", bg)
        // XCTAssertEqual(TrendsViewController.bloodGlucoseText(reading: bg), "72 mg/d")
    }

    func testHa1cTextReadingNil() {
        XCTAssertEqual(TrendsViewController.ha1cText(reading: nil), "No data")
    }

}
