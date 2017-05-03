//
//  SettingsViewController.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import SkyFloatingLabelTextField
import MBProgressHUD

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    var settingsDelegate: RoomySettingsDelegate!
    var newProfileImage: UIImage!
    var viewOriginalYPoint: CGFloat!
    
    let currentUser = Roomy.current()
    let imgPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        
        // Load existing user settings
        usernameTextField.placeholder = currentUser?.username
        emailTextField.placeholder = currentUser?.email
        
        if let imageFile = currentUser?.value(forKey: "profile_image") as? PFFile {
            imageFile.getDataInBackground(block: { (imgData: Data?, error: Error?) in
                if error == nil {
                    let userImage = UIImage(data: imgData!)
                    self.profileImage.image = userImage
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
        profileImage.layer.cornerRadius = 10
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.hideKeyboardWhenTappedAround()
        self.viewOriginalYPoint = self.view.frame.origin.y
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func didTapProfileImageView(_ sender: Any) {
        imgPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Do something with the images (based on your use case)
        let imageData = UIImagePNGRepresentation(image)
        let imageFile: PFFile? = PFFile(data: imageData!)!
        currentUser?.setObject(imageFile!, forKey: "profile_image")
        
        newProfileImage = image
        self.profileImage.image = image
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        let newUserName = usernameTextField.text
        
        //NOTE: make as switch statment
        if passwordTextField.text != ""{
            currentUser?.password = passwordTextField.text
        }
        
        if newUserName != "" {
            currentUser?.username = newUserName
        }
        
        if(emailTextField.text != ""){
            currentUser?.email = emailTextField.text
        }
        
        currentUser?.saveInBackground()
        
        if(self.newProfileImage == nil){
            self.newProfileImage = self.profileImage.image
        }
        
        self.dismiss(animated: true) { 
            self.settingsDelegate.updateRoomyProfile(userName: newUserName!, profileImage: self.newProfileImage)
        }
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onLogoutButtonTapped(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.animationType = .zoomIn
        
        PFUser.logOutInBackground { (error: Error?) in
            if error == nil {
                House._currentHouse = nil
                let mainStoryboard = UIStoryboard(name: R.Identifier.Storyboard.loginAndSignUp, bundle: nil)
                let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "UserLoginViewController") as! UserLoginViewController
                self.present(loginViewController, animated: true, completion: { 
                    hud.hide(animated: true, afterDelay: 1)
                })
            }
        }

        
    }
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.view.frame.origin.y -= keyboardSize.height / 4
                    
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

}





protocol RoomySettingsDelegate: class {
    func updateRoomyProfile(userName: String, profileImage: UIImage?)
}

