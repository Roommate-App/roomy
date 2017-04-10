//
//  House.swift
//  roomy
//
//  Created by Dustyn August on 3/18/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit
import Parse

class House: PFObject {
    
    // current house
    static var _currentHouse: House?
    
    // properties
    @NSManaged var address: String?
    @NSManaged var houseID: String?
    @NSManaged var password: String?
    @NSManaged var userIDs: [Roomy]?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    
    // constructor for House
    convenience init(address: String, houseID: String, password: String, userIDs: [Roomy], latitude: String, longitude: String) {
        self.init()
        
        self.address = address
        self.houseID = houseID
        self.password = password
        self.userIDs = userIDs
        self.latitude = latitude
        self.longitude = longitude
    }
    
    class func setCurrentHouse (house: House) {
        _currentHouse = house
    }
}

extension House: PFSubclassing {
    static func parseClassName() -> String {
        return "House"
    }
}

extension House {
    static func createHouse(address: String, houseID: String, password: String, userIDs: [Roomy], latitude: String, longitude: String, successful: @escaping (Bool) -> () , failure: @escaping (Error) ->()) {
        
        let house = House(address: address, houseID: houseID, password: password, userIDs: userIDs, latitude: latitude, longitude: longitude)
        
        house.saveInBackground { (_ success: Bool?, _ error: Error?) in
            if success! {
                setCurrentHouse(house: house)
                successful(success!)
            } else {
                print("Error creating house!")
                failure(error!)
            }
        }
    }
}
