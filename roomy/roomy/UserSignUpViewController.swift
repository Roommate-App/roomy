//
//  UserSignUpViewController.swift
//  roomy
//
//  Created by Poojan Dave on 3/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse


// Take logic of signing up user to the User class


// UserSignUpViewController: Signs up the user
class UserSignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ???
        emailTextField.becomeFirstResponder()

    }

    // signUpButtonPressed Action:
    // Extract the username, password, and email
    // Create new PFuser and populate the fields, then sign up the user and perform segue
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        let email = emailTextField.text!
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        let newUser = PFUser()
        newUser.email = email
        newUser.username = username
        newUser.password = password
        
        newUser["house"] = NSNull()
    
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                
                print("UserSignUpViewController/signUpButtonPressed(): New user created")
    
                self.performSegue(withIdentifier: "userSignUpToHouseLogin", sender: nil)
            } else {
                print("UserSignUpViewController/signUpButtonPressed() Error: \(error!.localizedDescription)")
            }
        }
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
