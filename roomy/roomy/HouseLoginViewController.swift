
//
//  HouseLoginViewController.swift
//  roomy
//
//  Created by Poojan Dave on 3/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import SkyFloatingLabelTextField


// HouseLoginViewController: Logs the user into a house and authenitcates their username and password
class HouseLoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var housenameTextField: SkyFloatingLabelTextFieldWithIcon!
    
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextFieldWithIcon!
    
    var viewOriginalYPoint: CGFloat!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(HouseLoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HouseLoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        housenameTextField.delegate = self
        viewOriginalYPoint = self.view.frame.origin.y
        self.hideKeyboardWhenTappedAround()
    }

    @IBAction func onCreateHomeButtonTapped(_ sender: Any) {
       let storyboard = UIStoryboard(name: R.Identifier.Storyboard.loginAndSignUp, bundle: nil)
        let creatHouseViewController = storyboard.instantiateViewController(withIdentifier: R.Identifier.ViewController.CreatHouseViewController) as! HouseSignUpViewController
        
        self.present(creatHouseViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func onSignInButtonTapped(_ sender: Any) {
        let housename = housenameTextField.text!
        let password = passwordTextField.text!
        
        switch "" {
        case housename:
            housenameTextField.errorMessage = "House name Requried"
            fallthrough
        case password:
            passwordTextField.errorMessage = "Password Required"
        default:
            signIntoHouse(housename, password)
        }
    }
    
    
    private func signIntoHouse(_ housename: String,_ password: String){
        let query = PFQuery(className: "House")
        query.whereKey("houseID", equalTo: housename)
        
        query.findObjectsInBackground { (housesReturned: [PFObject]?, error: Error?) in
            
            print(housesReturned?.count ?? "housesReturned.count failed")
            
            if let houses = housesReturned {
                
                for house in houses {
                    
                    if house["houseID"] as? String == housename {
                        
                        print("HouseID match")
                        
                        if house["password"] as? String == password {
                            
                            print("Password match")
                            
                            var userIDs = house["userIDs"] as! [PFUser]
                            userIDs.append(PFUser.current()!)
                            house["userIDs"] = userIDs
                            house.saveInBackground()
                            
                            PFUser.current()?["house"] = house
                            PFUser.current()?.saveInBackground()
                            
                            House.setCurrentHouse(house: house as! House)
                            
                            let storyboard = UIStoryboard(name: R.Identifier.Storyboard.tabBar, bundle: nil)
                            let tabBarController = storyboard.instantiateViewController(withIdentifier: R.Identifier.ViewController.tabBarViewController)
                            self.present(tabBarController, animated: true, completion: nil)
                        
                        } else {
                            print("Password failed")
                        }
                        
                    } else {
                        print("HouseID failed")
                    }
                }
            // Error
            } else {
                print("HouseLoginViewController/logInButtonPressed() Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        clearTextFieldErrorMessages()
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.view.frame.origin.y = self.viewOriginalYPoint
                })
            }
        }
    }
    
    func clearTextFieldErrorMessages(){
        housenameTextField.errorMessage = ""
        passwordTextField.errorMessage = ""
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        clearTextFieldErrorMessages()
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        clearTextFieldErrorMessages()
        return true
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
