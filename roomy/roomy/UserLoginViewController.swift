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


class UserLoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.becomeFirstResponder()
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        
         let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
         hud.mode = MBProgressHUDMode.indeterminate
        
        
        let username = userNameTextField.text!
        let password = passwordTextField.text!
        
        if username == "" {
            print("Username field is empty")
        } else if password == "" {
            print("Password field is empty")
        } else {
            Roomy.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
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
