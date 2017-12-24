//
//  Event.swift
//  NextAcademy - iOS 2Days Assessment (Oct 2017)
//
//  Created by Tan Wei Liang on 23/12/2017.
//  Copyright © 2017 Tan Wei Liang. All rights reserved.
//

import Foundation

class Event {
    var name : String = ""
    var date : String = ""
    var time : String = ""
    var venue : String = ""
    var latitude : Double = 0.0
    var longtitude : Double = 0.0
    var imageURL : String = ""
    
    static var currentEvent : Event?
    
    init(aName : String , aDate : String, aTime : String, aVenue : String, aLatitude : Double, aLongtitude : Double , anImageURL : String) {
        name = aName
        date = aDate
        time = aTime
        venue = aVenue
        latitude = aLatitude
        longtitude = aLongtitude
        imageURL = anImageURL
    }
    
    
    
}
