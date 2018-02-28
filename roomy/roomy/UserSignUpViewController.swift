//
//  UserSignUpViewController.swift
//  roomy
//
//  Created by Ryan Liszewski and Dustyn August
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import SkyFloatingLabelTextField
import FontAwesome_iOS
import IBAnimatable
import MBProgressHUD




// Take logic of signing up user to the User class


// UserSignUpViewController: Signs up the user
class UserSignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var viewOriginalYPoint: CGFloat!
    
    var profileImage: PFFile!
    
    @IBOutlet weak var profileImageLabel: UILabel!

    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!

  
    @IBOutlet weak var roomynameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var roomyPosterView: AnimatableImageView!
    @IBOutlet weak var addPhotoButton: AnimatableButton!
    
    let imagePicker = UIImagePickerController()
    var hud = MBProgressHUD()
    
    let storyb = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(UserSignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserSignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.hideKeyboardWhenTappedAround()
        
        viewOriginalYPoint = view.frame.origin.y
        
        emailTextField.delegate = self
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    private func displayProgressHud(){
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate

    }
    
    private func hideProgressHud(){
        hud.hide(animated: true, afterDelay: 20)
    }

    
    @IBAction func onBecomeARoomyButtonTapped(_ sender: Any) {
        displayProgressHud()
        
        let roomyname = roomynameTextField.text!
        let password = passwordTextField.text!
        let email = emailTextField.text!
        
        
        switch "" {
        case roomyname:
            roomynameTextField.errorMessage = "Roomy Name requried"
            fallthrough
        case email:
            emailTextField.errorMessage = "Email Required"
            fallthrough
        case password:
            passwordTextField.errorMessage = "Password required"
        default:
            createRoomy(roomyname, password, email)
        }
        
    }
    
    private func createRoomy(_ roomyname: String,_ password: String ,_ email: String){
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.animationType = .zoomIn
        Roomy.createUser(username: roomyname, password: password, email: email, profileImage: profileImage, status: "", successful: { (_ successful: Bool) in
            if(successful){
                hud.hide(animated: true, afterDelay: 10)
                self.performSegue(withIdentifier: R.Identifier.Segue.WelcomeToRoomySegue, sender: nil)
            }

        }, failure: { (_ error: Error) in
            self.hideProgressHud()
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
  
    @IBAction func onAddPhotoButtonTapped(_ sender: Any) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Get the image captured by the UIImagePickerController
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let resizedImage = image.resized(withPercentage: 0.1)
        
        // Do something with the images (based on your use case)
        let imageData = UIImagePNGRepresentation(resizedImage!)
        
        profileImage = PFFile(name: "image.png", data: imageData!)!
        
        // Dismiss UIImagePickerController to go back to your original view controller
        addPhotoButton.isHidden = true
        self.roomyPosterView.image = image
        profileImageLabel.text = "Profile Image"
        dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
