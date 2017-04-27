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
    var statusNumber: Int?

    convenience init(username: String, password: String, email: String, statusNumber: Int) {
        self.init()
        
        self.username = username
        self.password = password
        self.email = email
    }
}

extension Roomy {
    static func createUser(username: String, password: String, email: String, statusNumber: Int, successful: @escaping (Bool) -> (), failure: @escaping (Error) -> () ) {
        
        let roomy = Roomy(username: username, password: password, email: email, statusNumber: statusNumber)
        
            do {
                try roomy.signUp()
                print("Successfully signed up a user: User.swift")
                successful(true)
            }
            catch let error as Error?{
                print("Error signing up user: \(error?.localizedDescription) in User.swift")
                failure(error!)
            }
    }
}




