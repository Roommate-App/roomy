//
//  Roomy.swift
//  roomy
//
//  Created by Dustyn August on 4/8/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse

class Roomy: PFUser {
    
    var profileImage: PFFile?
    var status: String?
    var house: House?


    convenience init(username: String, password: String, email: String, profileImage: PFFile, status: String) {

        self.init()
        
        self.username = username
        self.password = password
        self.email = email

        self.profileImage = profileImage

        self.status = status

    }
}

extension Roomy {


        static func createUser(username: String, password: String, email: String,profileImage: PFFile, status: String, successful: @escaping (Bool) -> (), failure: @escaping (Error) -> () ) {
        
        let roomy = Roomy(username: username, password: password, email: email,profileImage: profileImage, status: status)
            
            do {
                try roomy.signUp()
                roomy["profile_image"] = profileImage
                try roomy.save()
                print("Successfully signed up a user: User.swift")
                successful(true)
            }
            catch let error as Error?{
                print("Error signing up user: \(error?.localizedDescription) in User.swift")
                failure(error!)
            }
            
//            let currentRoomy = Roomy.current()
//            currentRoomy?.setObject(profileImage, forKey: "profile_image")
//            currentRoomy?.setObject(status, forKey: "status")
//            currentRoomy?.saveInBackground()

    }
}




