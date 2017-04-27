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


class UserLoginViewController: UIViewController {
    

    var viewOriginalYPoint: CGFloat!
    
    @IBOutlet var roomyNameTextField: SkyFloatingLabelTextFieldWithIcon!
    
    @IBOutlet var passwordTextField: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var loginStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(UserLoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserLoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
         self.hideKeyboardWhenTappedAround()
        viewOriginalYPoint = view.frame.origin.y
        
    }
    
    
    @IBAction func onSignInButtonTapped(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
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
    

    @IBAction func loginButtonPressed(_ sender: Any) {
        
         let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
         hud.mode = MBProgressHUDMode.indeterminate
        
        let username = roomyNameTextField.text!
        let password = passwordTextField.text!
        
        if username == "" {
            print("Username field is empty")
        } else if password == "" {
            print("Password field is empty")
        } else {
            Roomy.logInWithUsername(inBackground: username, password: "") { (user: PFUser?, error: Error?) in
                if user != nil {
                    if user?["house"] != nil {
                        let house = Roomy.current()?["house"] as! House
                        print(house)
                        house.fetchInBackground(block: { (houseReturned: PFObject?, error: Error?) in
                            if houseReturned != nil {
                                House.setCurrentHouse(house: houseReturned! as! House)
                                self.performSegue(withIdentifier: "userLoginToTabBar", sender: nil)
                                hud.hide(animated: true, afterDelay: 20.0)
                            } else {
                                print("UserLoginViewController/loginButtonPressed() Retrieving House Error: \(String(describing: error?.localizedDescription))")
                            }
                        })
                    } else {
                        self.performSegue(withIdentifier: "userLoginToHouseLogin", sender: nil)
                        hud.hide(animated: true, afterDelay: 20.0)
                    }
                } else {
                    print("UserLoginViewController/loginButtonPressed() Logging in Error: \(String(describing: error?.localizedDescription))")
                    hud.hide(animated: true, afterDelay: 20.0)
                }
            }
        }
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
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
