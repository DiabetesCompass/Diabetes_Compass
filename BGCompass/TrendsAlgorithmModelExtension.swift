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
    Creates [BGReadingLight] from [BGReading]
    - returns: array of BGReadingLight.
    returns empty array [] if bgReadings is empty.
    */
    class func bgReadingLights(bgReadings: [BGReading]) -> [BGReadingLight] {
        var bgLights: [BGReadingLight] = []

        for bgReading in bgReadings {
            let bgReadingLight = BGReadingLight(bgReading: bgReading)
            bgLights.append(bgReadingLight)
        }
        return bgLights
    }

    /**
    - returns: first reading in blood glucose array, else nil
    based on index, not date
    */
    func bgArrayReadingFirst() -> BGReading? {
        return self.getFromBGArray(0)
    }

    /**
    - returns: last element in blood glucose array, else nil
    based on index, not date
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
    based on index, not date
     */
    func ha1cArrayReadingFirst() -> Ha1cReading? {
        return self.getFromHa1cArray(0)
    }

    /**
     - returns: last reading in HA1c array, else nil
    based on index, not date
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
//    func bloodGlucoseReadings(_ readings: [BGReading],
//                              startDate: Date,
//                              endDate: Date) -> [BGReading] {
//
//        // Swift 3 Date is a struct, implements comparable, can be compared using < >
//        // NSDate is an object.
//        // Need to use something like comparisonResult .orderedAscending
//        // Using < on NSDate would compare memory addresses.
//        // http://stackoverflow.com/questions/26198526/nsdate-comparison-using-swift#28109990
//        let readingsBetweenDates = readings
//            .filter( { ($0.timeStamp != nil)
//                && ($0.timeStamp >= startDate)
//                && ($0.timeStamp <= endDate) } )
//        return readingsBetweenDates
//    }

    // MARK: -

    /**
     - parameter bgReadings: blood glucose readings to average. quantity units mmol/L
     readings may appear in any chronological order, the method reads their timeStamp
     - parameter date: date for ha1cValue. Blood glucose readings after date are ignored.
     - parameter decayLifeSeconds: time for blood glucose from a reading to decay to 0.0.
     Typically hemoglobin lifespan seconds.
     - returns: ha1c value based on average of decayed BG reading.quantity
     */
    class func ha1cValueForBgReadings(_ bgReadings: [BGReading],
                                      date: Date,
                                      decayLifeSeconds: TimeInterval) -> Float {

        let averageDecayedBG = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadings,
                                                                                    date: date,
                                                                                    decayLifeSeconds: decayLifeSeconds)

        let ha1cValue = hA1c(bloodGlucoseMmolPerL: averageDecayedBG)
        return ha1cValue
    }
    
    /**
    This method uses BGReading, a CoreData managed object.
     - parameter bgReadings: BGReading readings to average.
       readings may appear in any chronological order, the method reads their timeStamp
     - parameter date: date for quantity. Blood glucose readings after date are ignored.
     - parameter decayLifeSeconds: time for blood glucose from a reading to decay to 0.0.
     Typically hemoglobin lifespan seconds.
     - returns: average of decayed BG reading.quantity
     */
    class func averageDecayedBGReadingQuantity(_ bgReadings: [BGReading],
                                        date: Date,
                                        decayLifeSeconds: TimeInterval) -> Float {

        // create [BGReadingLight] from [BGReading]
        let bgReadingLights = TrendsAlgorithmModel.bgReadingLights(bgReadings: bgReadings)
        let averageDecayedBG = TrendsAlgorithmModel.averageDecayedBGReadingQuantity(bgReadingLights,
                                                                                    date: date,
                                                                                    decayLifeSeconds: decayLifeSeconds)
        return averageDecayedBG
    }

    /**
    This method uses BGReadingLight, and may be tested without a CoreData context.
     - parameter bgReadingLights: BGReadingLight readings to average.
       readings may appear in any chronological order, the method reads their timeStamp
     - parameter date: date for quantity. Blood glucose readings after date are ignored.
     - parameter decayLifeSeconds: time for blood glucose from a reading to decay to 0.0.
     Typically hemoglobin lifespan seconds.
     - returns: average of decayed BG reading.quantity
     */
    class func averageDecayedBGReadingQuantity(_ bgReadingLights: [BGReadingLight],
                                        date: Date,
                                        decayLifeSeconds: TimeInterval) -> Float {

        if bgReadingLights.count == 0 {
            return 0.0
        }

        var sumOfWeightedBgReadings: Float = 0.0
        var sumOfWeights: Float = 0.0

        for bgReadingLight in bgReadingLights {

            if bgReadingLight.timeStamp > date {
                // skip this reading, continue loop
                continue
            }

            let weight = TrendsAlgorithmModel.weightLinearDecayFirstDate(bgReadingLight.timeStamp,
                                                                         secondDate: date,
                                                                         decayLifeSeconds: decayLifeSeconds)

            sumOfWeightedBgReadings += weight * bgReadingLight.quantity
            sumOfWeights += weight
        }

        // avoid potential divide by 0
        if sumOfWeights == 0 {
            return 0.0
        }
        let average = sumOfWeightedBgReadings / sumOfWeights
        print("averageDecayedBGReadingQuantity \(average)")
        return average
    }

    /**
     weight that decreases linearly from 1 to 0 as firstDate decreases from secondDate to (secondDate - decayLifeSeconds).
     - parameter firstDate: date at which weight is calculated
     - parameter secondDate: Occurs after firstDate. At this date or later weight is 1.0
     - parameter decayLifeSeconds: time for weight to decay to 0.0. Typically hemoglobin lifespan seconds.
     - returns: weight from 0.0 to 1.0 inclusive.
     returns 0.0 if firstDate is decayLifeSeconds or more before secondDate
     returns 1.0 if firstDate is on or after secondDate
     */
     class func weightLinearDecayFirstDate(_ firstDate: Date, secondDate: Date, decayLifeSeconds: TimeInterval) -> Float {

         let timeIntervalSecondDateSinceFirst = secondDate.timeIntervalSince(firstDate)

         var weight: Float = 0.0;
         if timeIntervalSecondDateSinceFirst >= decayLifeSeconds {
             // firstDate is decayLifeSeconds or more before secondDate
             weight = 0.0;
         } else if timeIntervalSecondDateSinceFirst <= 0 {
             // firstDate is on or after secondDate
             weight = 1.0
         } else {
             weight = Float(1.0 - (timeIntervalSecondDateSinceFirst/decayLifeSeconds))
         }
         return weight
     }

    /**
     Ha1c units are percent of hemoglobin that is glycated.
     Generally physiologic HA1c is >= 5.
     5 represents 5%, or 0.05
     https://en.wikipedia.org/wiki/Glycated_hemoglobin
     - parameter bloodGlucoseMmolPerL: blood glucose quantity, units mmol/L
     - returns: HA1c in DCCT percentage
     */
    class func hA1c(bloodGlucoseMmolPerL: Float) -> Float {
        let bloodGlucoseMgPerDl = bloodGlucoseMmolPerL * MG_PER_DL_PER_MMOL_PER_L
        let hA1cFromBg = (bloodGlucoseMgPerDl + 46.7) / 28.7
        return hA1cFromBg
    }

}
