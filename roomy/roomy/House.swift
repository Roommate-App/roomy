//
//  House.swift
//  roomy
//
//  Created by Poojan Dave on 3/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse

// House model: holds the current house and the ability to set it
// properties and constructor to initialize
class House: NSObject {
    
    // current house
    static var _currentHouse: House?
    
    // properties
    var address: String?
    var houseID: String?
    var password: String?
    var userIDs: [PFUser]? = []
    
    
    // constructor for House
    init(address: String?, houseID: String?, password: String?, userIDs: [PFUser]?) {
        self.address = address
        self.houseID = houseID
        self.password = password
        self.userIDs = userIDs
    }
    
    
    // setCurrentHouse sets the current house
    // Recieves a PFObject and parses through it to retrieve the proper values.
    // Then it creates a House object and saves it
    class func setCurrentHouse (house: PFObject) {
        
        // Extract proper values
        let address = house["address"] as! String?
        let houseID = house["houseID"] as! String?
        let password = house["password"] as! String?
        let userIDs = house["userIDs"] as! [PFUser]?
        
        // Create new House object
        let newHouse = House.init(address: address, houseID: houseID, password: password, userIDs: userIDs!)
        
        // Save current house
        _currentHouse = newHouse
        
    }
    
    
//    // Adds the username of the current user to the userIDs array
//    class func addNewUser() {
//        
//        // Retrieve the username of the current user
//        let username = PFUser.current()?.username
//        
//        // Add the username to the array of user IDs of the current house
//        _currentHouse?.userIDs?.append(username!)
//        
//        let objectIDNeeded = _currentHouse?.objectID
//                
//        let query = PFQuery(className:"House")
//        query.getObjectInBackground(withId: objectIDNeeded!) { (house: PFObject?, error: Error?) in
//            house?["userIDs"] = _currentHouse?.userIDs
//            house?.saveInBackground()
//        }
//        
//        PFUser.current()?["HouseID"] = _currentHouse
//        PFUser.current()?.saveInBackground()
//
//    }
//    
    
//    // creates new House; called by HouseSignUpViewController
//    // First creates a new PFObject, then parses through the House object to set the keys
//    // Then it pushes it to Parse and saves the current User after success
//    class func createNewHouse(house: House, withCompletion completion: PFBooleanResultBlock?) {
//        
//        // create newHouse as a PFObject; class House
//        let newHouse = PFObject(className: "House")
//        
//        // save the address, houseID, and password as keys
//        newHouse["address"] = house.address
//        newHouse["houseID"] = house.houseID
//        newHouse["password"] = house.password
//        newHouse["userIDs"] = house.userIDs
//        
//        // save in background; save to Parse
//        newHouse.saveInBackground { (success: Bool, error: Error?) in
//            
//            //set the current house
//            setCurrentHouse(house: newHouse)
//            
//        }
//        
//    }

    
    
//    class var currentHouse: House? {
//        get {
//            if _currentHouse == nil {
//                
//                //userDefault to store the value of current user across restarts
//                let userDefaults = UserDefaults.standard
//                
//                //retrieve the previous current user
//                let currentHouseExists = userDefaults.object(forKey: "currentHouse") as? House
//                
//                //safely uwrap the userData
//                if let currentHouseExists = currentHouseExists {
//                    
//                        //setting the current user to stored user (in userDefaults)
//                        _currentHouse = currentHouseExists
//                    
//                }
//            }
//            return _currentHouse
//        }
//        
//        //setting a current user
//        set(house) {
//            
//            //Sets currentUser with new user
//            _currentHouse = house
//            
//            //initialize userDefaults
//            let userDefaults = UserDefaults.standard
//            
//            //Safely unwrapping user
//            if let house = house {
//                
//                //Saving the userData with key in UserDefaults
//                userDefaults.set(house, forKey: "currentHouse")
//                
//                //if user is empty
//            } else {
//                
//                //Saving nil with key in userDefaults
//                userDefaults.set(nil, forKey: "currentHouse")
//            }
//            
//            //synchronize() method saves the data
//            userDefaults.synchronize()
//        }
//    }
    
    

    
    
    //    class func logIntoHouse(houseID: String?, password: String?) -> Bool {
    //
    //        var returnTrueOrFalse: Bool = false
    //
    //        // Makes the query and specifies the class
    //        let query = PFQuery(className: "House")
    //        // orders the posts by createdAt
    //        query.whereKey("houseID", equalTo: houseID!)
    //
    //        // send query through built-in Parse method
    //        // Returns the an array of Posts
    //        query.findObjectsInBackground { (houses: [PFObject]?, error: Error?) in
    //
    //            // If posts are not nil
    //            if let houses = houses {
    //
    //                for house in houses {
    //
    //                    if house["houseID"] as? String == houseID {
    //                        print("HouseID match")
    //                        if house["password"] as? String == password {
    //                            returnTrueOrFalse = true
    //                        }
    //                    }
    //
    //                }
    //
    //                // Error
    //            } else {
    //                print("TimelineViewController/networkCall Error: \(error?.localizedDescription)")
    //            }
    //            
    //        }
    //        
    //        return returnTrueOrFalse
    //        
    //        
    //    }
    

}


