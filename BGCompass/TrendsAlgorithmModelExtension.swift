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
 */
extension TrendsAlgorithmModel {

    /**
    - returns: first reading in blood glucose array, else nil
    */
    func bgArrayReadingFirst() -> BGReading? {
        return self.getFromBGArray(0)
    }

    /**
     - returns: first reading in HA1c array, else nil
     */
    func ha1cArrayReadingFirst() -> Ha1cReading? {
        return self.getFromHa1cArray(0)
    }

}
