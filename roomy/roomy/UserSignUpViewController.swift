//
//  UserSignUpViewController.swift
//  roomy
//
//  Created by Ryan Liszewski and Dustyn August
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4


// Take logic of signing up user to the User class


// UserSignUpViewController: Signs up the user
class UserSignUpViewController: UIViewController {
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    // signUpButtonPressed Action:
    // Extract the username, password, and email
    // Create new PFuser and populate the fields, then sign up the user and perform segue
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        
//        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile", "email"]) { (user: PFUser?, error: Error? ) in
//            if let user = user {
//                print("LOGGED IN")
//            }
//        }
        
//        
//        Roomy.createUser(username: usernameTextField.text!, password: passwordTextField.text!, email: emailTextField.text!, successful: { (_ successful: Bool) in
//                print("Successful user creation: UserSignUpViewController")
//                self.performSegue(withIdentifier: "userSignUpToHouseLogin", sender: nil)
//        }, failure: { (_ error: Error) in
//                print("Error creating a user: UserSignUpViewController")
//        })
//
//    }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
