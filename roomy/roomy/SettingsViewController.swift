//
//  SettingsViewController.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    let currentUser = Roomy.current()
    let imgPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        
        usernameTextField.text = currentUser?.username
        emailTextField.text = currentUser?.email
    }
    
    @IBAction func didTapProfileImageView(_ sender: Any) {
        imgPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        currentUser?.username = usernameTextField.text
        if passwordTextField.text != "123456" {
            currentUser?.password = passwordTextField.text
        }
        currentUser?.email = emailTextField.text
        currentUser?.saveInBackground()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
