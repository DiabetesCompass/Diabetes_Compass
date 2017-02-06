//
//  TrendsAlgorithmModelTests.swift
//  BGCompass
//
//  Created by Steve Baker on 12/18/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import XCTest
@testable import BGCompass

class TrendsAlgorithmModelTests: XCTestCase {

    // MARK: - test hA1cFromBloodGlucose

    func testHA1cFromBloodGlucoseZero() {
        //https://en.wikipedia.org/wiki/Glycated_hemoglobin
        // BGReading.quantity units mmol/L
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1c(bloodGlucoseMmolPerL: 0.0),
                                   1.62718, accuracy: 0.02)
    }

    func testHA1cFromBloodGlucose97() {
        //https://en.wikipedia.org/wiki/Glycated_hemoglobin
        // BGReading.quantity units mmol/L
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1c(bloodGlucoseMmolPerL: 97.0 / MG_PER_DL_PER_MMOL_PER_L),
                                   5.0, accuracy: 0.02)
    }

    func testHA1cFromBloodGlucose100() {
        //https://en.wikipedia.org/wiki/Glycated_hemoglobin
        // BGReading.quantity units mmol/L
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1c(bloodGlucoseMmolPerL: 100.0 / MG_PER_DL_PER_MMOL_PER_L),
                                   5.11, accuracy: 0.02)
    }

    func testHA1cFromBloodGlucose200() {
        //https://en.wikipedia.org/wiki/Glycated_hemoglobin
        // BGReading.quantity units mmol/L
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1c(bloodGlucoseMmolPerL: 200.0 / MG_PER_DL_PER_MMOL_PER_L),
                                   8.59, accuracy: 0.02)
    }

    func testHA1cFromBloodGlucose240() {
        //https://en.wikipedia.org/wiki/Glycated_hemoglobin
        // BGReading.quantity units mmol/L
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1c(bloodGlucoseMmolPerL: 240.0 / MG_PER_DL_PER_MMOL_PER_L),
                                   10.0, accuracy: 0.02)
    }

    func testHA1cFromBloodGlucose499() {
        //https://en.wikipedia.org/wiki/Glycated_hemoglobin
        // BGReading.quantity units mmol/L
        XCTAssertEqualWithAccuracy(TrendsAlgorithmModel.hA1c(bloodGlucoseMmolPerL: 499.0 / MG_PER_DL_PER_MMOL_PER_L),
                                   19.0, accuracy: 0.02)
    }

    // MARK: - test weightLinearDecay

    func testWeightLinearDecayFirstDateSecondDateSame() {
        let firstDate = Date()
        let secondDate = firstDate
        // use arbitrary value for test
        let decayLifeSeconds = 42.0

        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: decayLifeSeconds)
        XCTAssertEqualWithAccuracy(weight, 1.0, accuracy: 0.01)
    }

    func testWeightLinearDecayFirstDateLifetimeBeforeSecondDate() {
        let firstDate = Date()
        let secondDate = firstDate.addingTimeInterval(TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        XCTAssertEqualWithAccuracy(weight, 0.0, accuracy: 0.01)
    }

    func testWeightLinearDecayFirstDateBeforeSecondDateByOneTenthDecayLife() {
        let firstDate = Date()
        let secondDate = firstDate.addingTimeInterval(0.1 * TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        // weight will be close to 1.0
        XCTAssertEqualWithAccuracy(weight, 0.90, accuracy: 0.01)
    }

    func testWeightLinearDecayFirstDateBeforeSecondDateByNineTenthsDecayLife() {
        let firstDate = Date()
        // use arbitrary value for test, one hour
        let decayLifeSeconds = 3600.0
        let secondDate = firstDate.addingTimeInterval(0.9 * decayLifeSeconds)
        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: decayLifeSeconds)
        // weight will be close to 0.0
        XCTAssertEqualWithAccuracy(weight, 0.10, accuracy: 0.01)
    }

    func testWeightLinearDecayFirstDateDistantPast() {
        let firstDate = Date.distantPast
        let secondDate = Date()

        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        XCTAssertEqualWithAccuracy(weight, 0.0, accuracy: 0.01)
    }

    func testWeightLinearDecayFirstDateAfterSecondDate() {

        let firstDate = Date.distantFuture
        let secondDate = Date()

        let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(firstDate,
                                                                     secondDate: secondDate,decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        XCTAssertEqualWithAccuracy(weight, 1.0, accuracy: 0.01)
    }

    // MARK: - test bgReadingLights

    func testBgReadingLightsEmpty() {
        let bgReadingLights = TrendsAlgorithmModel.bgReadingLights(bgReadings: [])
        XCTAssertEqual(bgReadingLights.count, 0)
    }

    func testBgReadingLights() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings135(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)
        let bgReadingLights = TrendsAlgorithmModel.bgReadingLights(bgReadings: bgReadings)
        XCTAssertEqual(bgReadingLights.count, bgReadings.count)
    }

    // MARK: - test averageDecayedBGReadingQuantity

    func testAverageDecayedBGReadingQuantity200EndDateNow() {

        let accuracy: Float = 0.1

        let date = Date()
        let quantity = 200.0 / MG_PER_DL_PER_MMOL_PER_L
        XCTAssertEqualWithAccuracy(quantity, 11.0999, accuracy: accuracy)

        let bgReadingLight0 = BGReadingLight(timeStamp: date, quantity: quantity)
        let bgReadingLights = [bgReadingLight0]

        let endDate = date

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date:endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        XCTAssertEqualWithAccuracy(actual, quantity, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantity200EndDateHalfHemoglobinDecayLifetime() {

        let accuracy: Float = 0.01
        let date = Date()
        let quantity = 200.0 / MG_PER_DL_PER_MMOL_PER_L
        XCTAssertEqualWithAccuracy(quantity, 11.0999, accuracy: accuracy)
        let bgReadingLight0 = BGReadingLight(timeStamp: date, quantity: quantity)
        let bgReadingLights = [bgReadingLight0]

        let endDate = date.addingTimeInterval(0.5 * TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date:endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        // FIXME: this should be >0 and < quantity
        XCTAssertEqualWithAccuracy(actual, quantity, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantity200EndDateHemoglobinDecayLifetime() {

        let accuracy: Float = 0.01
        let date = Date()
        let quantity = 200.0 / MG_PER_DL_PER_MMOL_PER_L
        let bgReadingLight0 = BGReadingLight(timeStamp: date, quantity: quantity)
        let bgReadingLights = [bgReadingLight0]

        let endDate = date.addingTimeInterval(TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date:endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        XCTAssertEqualWithAccuracy(actual, 0.00, accuracy: accuracy)
    }

    // MARK: blood glucose 135

    func testAverageDecayedBGReadingQuantity135() {

        let endDate = Date()
        let bgReadingLights = BGReadingLightsHelper.bgReadingLights135(endDate: endDate)
        XCTAssertEqual(bgReadingLights.count, 101)

        // check last reading date
        // this didn't work, though date descriptions appear identical
        //XCTAssertEqual(bgReadingLights.last?.timeStamp, endDate)
        let bgReadingsLastTimeStamp = bgReadingLights.last?.timeStamp
        let compareLast: ComparisonResult = Calendar.current.compare(bgReadingsLastTimeStamp!,
                                                                     to: endDate,
                                                                     toGranularity: .second)
        XCTAssertEqual(compareLast, .orderedSame)

        // check first reading date
        let bgReadingsFirstTimeStamp = bgReadingLights.first?.timeStamp
        let expectedFirstDate = endDate.addingTimeInterval(-TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        let compareFirst: ComparisonResult = Calendar.current.compare(bgReadingsFirstTimeStamp!,
                                                                      to: expectedFirstDate,
                                                                      toGranularity: .second)
        XCTAssertEqual(compareFirst, .orderedSame)
        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date:endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 135.0 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantityDateDistantPast() {

        let endDate = Date()
        let bgReadingLights = BGReadingLightsHelper.bgReadingLights135(endDate: endDate)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date: Date.distantPast,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        // all readings are after Date.distantPast and were ignored
        let expected: Float = 0.0
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantityDateDistantFuture() {

        let endDate = Date()
        let bgReadingLights = BGReadingLightsHelper.bgReadingLights135(endDate: endDate)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date: Date.distantFuture,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        // all readings are long before Date.distantFuture.
        // hemoglobin has decayed and their weights are 0.
        let expected: Float = 0.0
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    // MARK: blood glucose 135 and 170

    func testAverageDecayedBGReadingQuantityAlternating135and170() {

        let endDate = Date()
        let bgReadingLights = BGReadingLightsHelper.bgReadingsLightsAlternating135and170(endDate: endDate)
        XCTAssertEqual(bgReadingLights.count, 101)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 152.327 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    // MARK: blood glucose 150 and 50

    func testAverageDecayedBGReadingQuantityBgReadings50at150then50at50() {

        let endDate = Date()
        let bgReadingLights = BGReadingLightsHelper.bgReadingLights30at150then70at50(endDate: endDate)
        XCTAssertEqual(bgReadingLights.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 59.394 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    // MARK: blood glucose 50 and 150

    func testAverageDecayedBGReadingQuantityBgReadings50at50then50at150() {

        let endDate = Date()
        let bgReadingLights = BGReadingLightsHelper.bgReadingLights50at50then50at150(endDate: endDate)
        XCTAssertEqual(bgReadingLights.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 124.752 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    // MARK: 30 at 150 then 70 at 50

    func testAverageDecayedBGReadingQuantityBgReadings30at150then70at50() {

        let endDate = Date()
        let bgReadingLights = BGReadingLightsHelper.bgReadingLights30at150then70at50(endDate: endDate)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 59.394 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantityBgReadings30at150then70at50_20DaysAgo() {

        let bgReadingsLastDate = Date()
        let endDate = bgReadingsLastDate.addingTimeInterval(-20.0 * Double(SECONDS_PER_DAY))
        let bgReadingLights = BGReadingLightsHelper.bgReadingLights30at150then70at50(endDate: endDate)
        XCTAssertEqual(bgReadingLights.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)

        let expected: Float = 72.468 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    func testAverageDecayedBGReadingQuantityBgReadings30at150then70at50_29DaysAgo() {

        let bgReadingsLastDate = Date()

        let endDate = bgReadingsLastDate.addingTimeInterval(-29.0 * Double(SECONDS_PER_DAY))
        let bgReadingLights = BGReadingLightsHelper.bgReadingLights30at150then70at50(endDate: endDate)
        XCTAssertEqual(bgReadingLights.count, 100)

        // call method under test
        let actual = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                          date: endDate,
                                                                          decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        // MG_PER_DL_PER_MMOL_PER_L = 18.0182
        let expected: Float = 79.568 / MG_PER_DL_PER_MMOL_PER_L
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
    }

    // MARK: - testHa1cValueForBgReadings

    func testHa1cValueForBgReadings() {

        let endDate = Date()
        let bgReadings = BGReadingTestHelper.bgReadings135(endDate) as! [BGReading]
        XCTAssertEqual(bgReadings.count, 100)
        
        // call method under test
        let actual = TrendsAlgorithmModel.ha1cValueForBgReadings(bgReadings,
                                                                 date: endDate,
                                                                 decayLifeSeconds: TrendsAlgorithmModel.hemoglobinLifespanSeconds)
        
        let expected: Float = 6.331
        let accuracy: Float = 0.1
        XCTAssertEqualWithAccuracy(actual, expected, accuracy: accuracy)
        
    }
    
}
