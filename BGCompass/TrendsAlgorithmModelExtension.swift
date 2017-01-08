//
//  TrendsAlgorithmModelExtension.swift
//  BGCompass
//
//  Created by Steve Baker on 12/11/16.
//  Copyright © 2016 Clif Alferness. All rights reserved.
//

import Foundation

/** Swift extension can extend a Swift class or an Objective C class
 http://ctarda.com/2016/05/swift-extensions-can-be-applied-to-objective-c-types/
 If this was a class would add @objc, but apparently
 for an extension this annotation is not needed or allowed
 */
extension TrendsAlgorithmModel {

    // 100 days in seconds = days * hours/day * minutes/hour * seconds/minute
    public static let hemoglobinLifespanSeconds: TimeInterval = 100 * 24 * 60 * 60;

    // MARK: get readings

    /**
    - returns: first reading in blood glucose array, else nil
    */
    func bgArrayReadingFirst() -> BGReading? {
        return self.getFromBGArray(0)
    }

    /**
    - returns: last reading in blood glucose array, else nil
    */
    func bgArrayReadingLast() -> BGReading? {
        if self.bgArrayCount() == 0 {
            return nil
        } else {
            let index = UInt(self.bgArrayCount()) - 1
            return self.getFromBGArray(index)
        }
    }

    /**
     - returns: first reading in HA1c array, else nil
     */
    func ha1cArrayReadingFirst() -> Ha1cReading? {
        return self.getFromHa1cArray(0)
    }

    /**
     - returns: last reading in HA1c array, else nil
    */
    func ha1cArrayReadingLast() -> Ha1cReading? {
        if self.ha1cArrayCount() == 0 {
            return nil
        } else {
            let index = UInt(self.ha1cArrayCount()) - 1
            return self.getFromHa1cArray(index)
        }
    }


    /**
     - returns: readings between startDate (inclusive) and endDate (inclusive)
     */
    func bloodGlucoseReadings(_ readings: [BGReading],
                              startDate: Date,
                              endDate: Date) -> [BGReading] {

        // Swift 3 Date is a struct, implements comparable, can be compared using < >
        // NSDate is an object.
        // Need to use something like comparisonResult .orderedAscending
        // Using < on NSDate would compare memory addresses.
        // http://stackoverflow.com/questions/26198526/nsdate-comparison-using-swift#28109990
        let readingsBetweenDates = readings
            .filter( { ($0.timeStamp != nil)
                && ($0.timeStamp >= startDate)
                && ($0.timeStamp <= endDate) } )
        return readingsBetweenDates
    }

    // MARK: -

    /**
     - parameter bgReadings: blood glucose readings to average. quantity units mmol/L
     readings may appear in any chronological order, the method reads their timeStamp
     - parameter endDate: end date for decay. Blood glucose readings after endDate are ignored.
     - parameter decayLifeSeconds: time for blood glucose from a reading to decay to 0.0.
     Typically hemoglobin lifespan seconds.
     - returns: ha1c value based on average of decayed BG reading.quantity
     */
    class func ha1cValueForBgReadings(_ bgReadings: [BGReading],
                                      endDate: Date,
                                      decayLifeSeconds: TimeInterval) -> Float {

        let averageDecayedBG = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                                    endDate: endDate,
                                                                                    decayLifeSeconds: decayLifeSeconds)

        let ha1cValue = hA1cFromBloodGlucose(averageDecayedBG)
        return ha1cValue
    }
    
    /**
     - parameter bgReadings: blood glucose readings to average.
       readings may appear in any chronological order, the method reads their timeStamp
     - parameter endDate: end date for decay. Blood glucose readings after endDate are ignored.
     - parameter decayLifeSeconds: time for blood glucose from a reading to decay to 0.0.
     Typically hemoglobin lifespan seconds.
     - returns: average of decayed BG reading.quantity
     */
    class func averageDecayedBGReadingQuantity(_ bgReadings: [BGReading],
                                        endDate: Date,
                                        decayLifeSeconds: TimeInterval) -> Float {

        if bgReadings.count == 0 {
            return 0.0
        }

        var sumOfWeightedBgReadings: Float = 0.0
        var sumOfWeights: Float = 0.0

        for bgReading in bgReadings {

            if bgReading.timeStamp > endDate {
                // skip this reading, continue loop
                continue
            }

            let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(bgReading.timeStamp,
                                                                         secondDate: endDate,decayLifeSeconds: decayLifeSeconds)

            sumOfWeightedBgReadings += weight * bgReading.quantity.floatValue
            sumOfWeights += weight
        }

        // avoid potential divide by 0
        if sumOfWeights == 0 {
            return 0.0
        }
        return sumOfWeightedBgReadings / sumOfWeights
    }

    /**
     weight linearly decaying over time range (secondDate - decayLifeSeconds) to secondDate
     - parameter firstDate: date at which weight is calculated
     - parameter secondDate: second date. At this date or later weight is 1.0
     - parameter decayLifeSeconds: time for weight to decay to 0.0. Typically hemoglobin lifespan seconds.
     - returns: weight from 0.0 to 1.0 inclusive.
     returns 0.0 if firstDate is decayLifeSeconds or more before secondDate
     returns 1.0 if firstDate is on or after secondDate
     */
    class func weightLinearDecayFirstDate(_ firstDate: Date,
                                          secondDate: Date,
                                          decayLifeSeconds: TimeInterval) -> Float {
        let timeIntervalFromFirstToSecond = secondDate.timeIntervalSince(firstDate)
        // weightUnclamped may be < 0.0 or > 1.0
        let weightUnclamped = 1.0 - (timeIntervalFromFirstToSecond/decayLifeSeconds)
        var weight: Float = 0.0;
        if weightUnclamped < 0.0 {
            weight = 0.0;
        } else if weightUnclamped > 1.0 {
            weight = 1.0
        } else {
            weight = Float(weightUnclamped)
        }
        return weight
    }

    /**
     Generally physiologic HA1c is >= 5
     https://en.wikipedia.org/wiki/Glycated_hemoglobin
     - parameter bloodGlucose: blood glucose quantity, units mmol/L
     - returns: HA1c in DCCT percentage
     */
    class func hA1cFromBloodGlucose(_ bloodGlucose: Float) -> Float {
        let bloodGlucoseMgPerDl = bloodGlucose * MG_PER_DL_PER_MMOL_PER_L
        let hA1c = (bloodGlucoseMgPerDl + 46.7) / 28.7
        return hA1c
    }

}
