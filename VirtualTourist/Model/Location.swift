//
//  Location.swift
//  VirtualTourist
//
//  Created by Andrew Llewellyn on 7/29/18.
//  Copyright © 2018 Andrew Llewellyn. All rights reserved.
//

import Foundation
import UIKit


class Location: NSObject
{
    
    
    var latitude:  Double?
    
    var longitude: Double?
    
    
    
    
    
    class func sharedInstance() -> Location
    {
        struct Singleton
        {
            static var sharedInstance = Location()
        }
        return Singleton.sharedInstance
        
    }
}
