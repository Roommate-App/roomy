//
//  UserLoginViewController.swift
//  roomy
//
//  Created by Poojan Dave on 3/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse


// Figure out race conditions
// Segues from different files
// Move logic for signing in users to User model


// UserLoginViewController: Logs in the user and authenticates their username and password
// If user successfully logs in, go to tabBarController or HouseLoginViewController
class UserLoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ???????
        userNameTextField.becomeFirstResponder()

    }


    // loginButtonPressed Action: 
    // Extract the username and password, make sure username and password field are not empty,
    // Then use PFUser to log in,
    // If user has a house, then segue to tabBar
    // Else, segue to houseLogin
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        // Extract the username and password
        let username = userNameTextField.text!
        let password = passwordTextField.text!
        
        // Checking to see is the username and password are empty.
        if username == "" {
            print("Username field is empty")
        } else if password == "" {
            print("Password field is empty")
            
        // If username and password are not empty, then sign in
        } else {
            
            // Parse built-in method to log in an existing user. Sends username and password
            PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
                
                // If user is not empty, it means that they user logged in
                if user != nil {
                    
                    // If user has a house, then go to tabBar
                    if user?["house"] != nil {
                        
                        // Retrieve House and fetch
                        let house = PFUser.current()?["house"] as! PFObject
                        house.fetchInBackground(block: { (houseReturned: PFObject?, error: Error?) in
                            
                            // If house successfully fetched
                            if houseReturned != nil {
                                
                                House.setCurrentHouse(house: houseReturned!)
                                
                                self.performSegue(withIdentifier: "userLoginToTabBar", sender: nil)
                                
                            } else {
                                
                                print("UserLoginViewController/loginButtonPressed() Retrieving House Error: \(String(describing: error?.localizedDescription))")
                            }
                        })
                        
                    // If "HouseID" is nil, then go to HouseLoginViewController
                    } else {
                        
                        self.performSegue(withIdentifier: "userLoginToHouseLogin", sender: nil)
                        
                    }
                    
                // Error
                } else {
                    print("UserLoginViewController/loginButtonPressed() Logging in Error: \(String(describing: error?.localizedDescription))")
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

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
