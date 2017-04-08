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
    
    
    // constructor for House
    convenience init(address: String, houseID: String, password: String, userIDs: [Roomy]) {
        self.init()
        
        self.address = address
        self.houseID = houseID
        self.password = password
        self.userIDs = userIDs
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
    static func createHouse(address: String, houseID: String, password: String, userIDs: [Roomy],  successful: @escaping (Bool) -> () , failure: @escaping (Error) ->()) {
        
        let house = House(address: address, houseID: houseID, password: password, userIDs: userIDs)
        
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
