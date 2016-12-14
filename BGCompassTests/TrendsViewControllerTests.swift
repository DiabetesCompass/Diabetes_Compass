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

    func testArithmeticExample() {
        XCTAssertEqual(5, 2 + 3)
}

    func testBloodGlucoseTextReadingNil() {
        XCTAssertEqual(TrendsViewController.bloodGlucoseText(reading: nil), "No data")
    }

    func testHa1cTextReadingNil() {
        XCTAssertEqual(TrendsViewController.ha1cText(reading: nil), "No data")
    }

}
