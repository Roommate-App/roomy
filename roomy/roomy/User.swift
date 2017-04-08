//
//  User.swift
//  roomy
//
//  Created by Dustyn August on 4/5/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit
import Parse

class User: PFUser {
    
    var firstName: String?
    var lastName: String?
    var telephoneNumber: String?
    var house: House?
    
    convenience init(username: String, password: String, email: String) {
        self.init()
        
        self.username = username
        self.password = password
        self.email = email
    }
}

extension User {
    static func createUser(username: String, password: String, email: String, successful: @escaping (Bool) -> (), failure: @escaping (Error) -> () ) {
        
        let user = User(username: username, password: password, email: email)
    
        user.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("Successfully signed up a user: User.swift")
                successful(success)
            } else {
                print("Error signing up user: \(error?.localizedDescription) in User.swift")
                failure(error!)
            }
        }
    }
}

