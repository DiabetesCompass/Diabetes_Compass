//
//  BGReadingLight.swift
//  BGCompass
//
//  Created by Steve Baker on 2/5/17.
//  Copyright © 2017 Clif Alferness. All rights reserved.
//

import UIKit

/**
A "lightweight" version of BGReading that is not a CoreData managed object.
It may be instantiated from a BGReading, and is easy to use and test without a CoreData context.
*/
struct BGReadingLight {

    var timeStamp: Date
    var quantity: Float

    init(timeStamp: Date, quantity: Float) {
        self.timeStamp = timeStamp
        self.quantity = quantity
    }

    /// initialize with a BGReading
    init(bgReading: BGReading) {
        timeStamp = bgReading.timeStamp
        quantity = bgReading.quantity as Float
    }

}
