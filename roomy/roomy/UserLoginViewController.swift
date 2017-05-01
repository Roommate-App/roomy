//
//  UserLoginViewController.swift
//  roomy
//
//  Created by Poojan Dave on 3/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD
import IBAnimatable
import SkyFloatingLabelTextField


class UserLoginViewController: UIViewController, UITextFieldDelegate {
    

    var viewOriginalYPoint: CGFloat!
    
    @IBOutlet var roomyNameTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var passwordTextField: SkyFloatingLabelTextFieldWithIcon!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(UserLoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserLoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
        self.hideKeyboardWhenTappedAround()
        viewOriginalYPoint = view.frame.origin.y
        roomyNameTextField.delegate = self
        //passwordTextField.delegate = self
        
    }
    
    @IBAction func onSignInButtonTapped(_ sender: Any) {
        
        self.dismissKeyboard()
        
        let roomyname = roomyNameTextField.text!
        let password = passwordTextField.text!
        
        switch "" {
        case roomyname:
            roomyNameTextField.errorMessage = "Roomyname requried"
            fallthrough
        case password:
            passwordTextField.errorMessage = "Password requried"
        default:
            loginRoomy(roomyname, password)
        }
    }
    
    func loginRoomy(_ roomyname: String,_ password: String){
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        
        Roomy.logInWithUsername(inBackground: roomyname, password: password) { (user: PFUser?, error: Error?) in
            
            if user != nil {
                if user?["house"] != nil {
                    let house = Roomy.current()?["house"] as! House
                    print(house)
                    house.fetchInBackground(block: { (houseReturned: PFObject?, error: Error?) in
                        if houseReturned != nil {
                            House.setCurrentHouse(house: houseReturned! as! House)
                            
                            let storyboard = UIStoryboard(name: R.Identifier.Storyboard.tabBar, bundle: nil)
                            
                            
                            let tabBarController = storyboard.instantiateViewController(withIdentifier: R.Identifier.ViewController.tabBarViewController)
                            
                            
                            self.present(tabBarController, animated: true, completion: { 
                                hud.hide(animated: true, afterDelay: 20.0)
                            })
                            
                        } else {
                            print("UserLoginViewController/loginButtonPressed() Retrieving House Error: \(String(describing: error?.localizedDescription))")
                        }
                    })
                } else {
                    
                    let storyBoard = UIStoryboard(name: R.Identifier.Storyboard.loginAndSignUp, bundle: nil)
                    
                    let houseSignInViewController = storyBoard.instantiateViewController(withIdentifier: R.Identifier.ViewController.HouseLoginViewController) as! HouseLoginViewController
                    self.present(houseSignInViewController, animated: true, completion: nil)
                    hud.hide(animated: true, afterDelay: 20.0)
                }
            } else {
                print("UserLoginViewController/loginButtonPressed() Logging in Error: \(String(describing: error?.localizedDescription))")
                hud.hide(animated: true, afterDelay: 20.0)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        clearTextFieldErrorMessages()
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        clearTextFieldErrorMessages()
        return true
    }
    
    private func clearTextFieldErrorMessages(){
        //Have to set error message to nil or "" when clearing it
        roomyNameTextField.errorMessage = ""
        passwordTextField.errorMessage = ""
    }
    
    
    @IBAction func onRoomySignUpBottonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: R.Identifier.Storyboard.loginAndSignUp, bundle: nil)
        let userSignUpViewController = storyboard.instantiateViewController(withIdentifier: R.Identifier.ViewController.UserSignUpViewController) as! UserSignUpViewController
        
        self.present(userSignUpViewController, animated: true, completion: nil)
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))

        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
