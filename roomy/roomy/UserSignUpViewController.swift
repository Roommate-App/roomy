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
import SkyFloatingLabelTextField
import FontAwesome_iOS




// Take logic of signing up user to the User class


// UserSignUpViewController: Signs up the user
class UserSignUpViewController: UIViewController, UITextFieldDelegate {
    
    var viewOriginalYPoint: CGFloat!
    
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var roomynameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(UserSignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserSignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.hideKeyboardWhenTappedAround()
        
        viewOriginalYPoint = view.frame.origin.y
        
        emailTextField.delegate = self
    }

    
    @IBAction func onBecomeARoomyButtonTapped(_ sender: Any) {
        
        switch "" {
        case roomynameTextField.text!:
            roomynameTextField.errorMessage = "Roomy Name requried"
            fallthrough
        case emailTextField.text!:
            emailTextField.errorMessage = "Email Required"
            fallthrough
        case passwordTextField.text!:
            passwordTextField.errorMessage = "Password required"
        default: break
        }
        
        
        Roomy.createUser(username: roomynameTextField.text!, password: passwordTextField.text!, email: emailTextField.text!, successful: { (_ successful: Bool) in
            print("Successful user creation: UserSignUpViewController")
            self.performSegue(withIdentifier: "userSignUpToHouseLogin", sender: nil)
        }, failure: { (_ error: Error) in
            if(error.localizedDescription.contains("Account already exists for this email address.")){
                self.emailTextField.errorMessage = "Email already exists"
            }
        })
    }
    
    @IBAction func onBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK: TEXT FIELD DELEGATE FUNCTIONS
    func textFieldDidBeginEditing(_ textField: UITextField){
        resetTextFieldErrorMessages()
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
     return true
    }
    
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        
//        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile", "email"]) { (user: PFUser?, error: Error? ) in
//            if let user = user {
//                print("LOGGED IN")
//            }
//        }
        
    }
    
    
    func resetTextFieldErrorMessages(){
        //Error message only resets when we set it to nil or ""
        self.emailTextField.errorMessage = ""
        self.passwordTextField.errorMessage = ""
        self.roomynameTextField.errorMessage = ""
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                
                
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.view.frame.origin.y -= keyboardSize.height / 2
                    self.addPhotoButton.frame.origin.y += keyboardSize.height / 4
                })
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.view.frame.origin.y = self.viewOriginalYPoint
                    self.addPhotoButton.frame.origin.y -= keyboardSize.height / 4
                })
                
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}
