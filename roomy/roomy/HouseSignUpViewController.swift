//
//  HouseSignUpViewController.swift
//  roomy
//
//  Created by Dustyn August on 4/5/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit
import Parse

class HouseSignUpViewController: UIViewController {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var houseIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        addressTextField.becomeFirstResponder()
    }

    @IBAction func signUpButtonPressed(_ sender: Any) {
        House.createHouse(address: addressTextField.text!, houseID: houseIDTextField.text!, password: passwordTextField.text!, userIDs: [Roomy.current()!], successful:  { (_ successful: Bool) in
                print("Successfully created house: in HouseSignUp")
                self.performSegue(withIdentifier: "houseSignUpToTabBar", sender: nil)
            }, failure: { (_ error: Error) in
                print("Error creating house: in HouseSignUp")
        })
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
