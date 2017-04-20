//
//  SettingsViewController.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let currentUser = Roomy.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.text = currentUser?.username
        passwordTextField.text = currentUser?.password
        emailTextField.text = currentUser?.email
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        currentUser?.username = usernameTextField.text
        currentUser?.password = passwordTextField.text
        currentUser?.email = emailTextField.text
        currentUser?.saveInBackground()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
