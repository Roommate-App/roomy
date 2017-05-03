//
//  SettingsViewController.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    var settingsDelegate: RoomySettingsDelegate!
    
    let currentUser = Roomy.current()
    let imgPicker = UIImagePickerController()
    var newProfileImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgPicker.delegate = self
        //imgPicker.allowsEditing = true
        
        print(currentUser?.password)
        // Load existing user settings
        usernameTextField.text = currentUser?.username
        emailTextField.text = currentUser?.email
        
        
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
        currentUser?.username = newUserName
        if passwordTextField.text != "123456" {
            currentUser?.password = passwordTextField.text
        }
        currentUser?.email = emailTextField.text
        currentUser?.saveInBackground()
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true) { 
            self.settingsDelegate.updateRoomyProfile(userName: newUserName!, profileImage: self.newProfileImage)
        }
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

protocol RoomySettingsDelegate: class {
    func updateRoomyProfile(userName: String, profileImage: UIImage)
}

