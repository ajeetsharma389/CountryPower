//
//  utils.swift
//  Assigment_S
//
//  Created by Ajeet on 02/12/19.
//  Copyright © 2019 CG. All rights reserved.
//
/*
 This File is used for Date formatting 
 */

import Foundation

struct Utils {
    
    init() {}
    
    func getCurrentDateTime() -> String {
        
        let currentDate = Date()
        // create dateFormatter with current time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        let result = dateFormatter.string(from: currentDate)
        
        // create dateFormatter with yyyy-MM-dd'T'HH:mm:ss format
        let date = dateFormatter.date(from: result)// create   date from string
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        // change to a readable time format and change to local time zone
        dateFormatter.timeZone = NSTimeZone.local
        let curentDateTime = dateFormatter.string(from: date!)
        
        //print(curentDateTime)
        
        return curentDateTime
    }
    
    func getCurrentDate() -> String {
        
        let today = Date()
        // create dateFormatter with current time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +0000"
        let result = dateFormatter.string(from: today)
        // create dateFormatter with yyyy-MM-dd'T'HH:mm:ss format
        let date = dateFormatter.date(from: result)// create   date from string
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // change to a readable time format and change to local time zone
        dateFormatter.timeZone = NSTimeZone.local
        let currentDate = dateFormatter.string(from: date!)
        return currentDate
    }
    
}
