//
//  HouseSignUpViewController.swift
//  roomy
//
//  Created by Dustyn August on 4/5/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit
import Parse
import GooglePlaces
import SkyFloatingLabelTextField
import IBAnimatable


// Make sure only unique houseIDs are created (especially addresses)
// HouseSignUpViewController: Creates a new house
class HouseSignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    
    @IBOutlet weak var housenameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var addressTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var addHousePhotoButton: AnimatableButton!
    @IBOutlet weak var housePosterView: AnimatableImageView!
    var latitude: String?
    var longitude: String?
    
    var viewOriginalYPoint: CGFloat!
    
    let autocompleteController = GMSAutocompleteViewController()
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HouseSignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HouseSignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        autocompleteController.delegate = self
        self.hideKeyboardWhenTappedAround()
        viewOriginalYPoint = self.view.frame.origin.y
    }
    
    @IBAction func onBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onCreateAHomeButtonTapped(_ sender: Any) {
        let housename = housenameTextField.text!
        let address = addressTextField.text!
        let password = passwordTextField.text!
        
        switch "" {
        case housename:
            housenameTextField.errorMessage = "Housename required"
            fallthrough
        case address:
            addressTextField.errorMessage = "Location required"
            fallthrough
        case password:
            passwordTextField.errorMessage = "Password required"
        default:
            createHouse(housename, address, password)
        }
    }
    
    func createHouse(_ housename: String,_ address: String, _ password: String){
        House.createHouse(address: address, houseID: housename, password: password, userIDs: [Roomy.current()!], latitude: latitude!, longitude: longitude!,  successful:  { (_ successful: Bool) in
            
            self.performSegue(withIdentifier: R.Identifier.Segue.TabBarController, sender: nil)
        }, failure: { (_ error: Error) in
            print("Error creating house: in HouseSignUp")
        })
        
    }
    
    @IBAction func onAddressTextLabelTapped(_ sender: Any)  {
       
    }
    
    @IBAction func onAddHousePhotoButtonTapped(_ sender: Any) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func onAddressButtonTouched(_ sender: Any) {
        present(autocompleteController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        addressTextField.errorMessage = ""
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        clearTextFieldErrorMessages()
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        clearTextFieldErrorMessages()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Get the image captured by the UIImagePickerController
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Do something with the images (based on your use case)
        let imageData = UIImagePNGRepresentation(image)
        //profileImage = PFFile(data: imageData!)!
        
        // Dismiss UIImagePickerController to go back to your original view controller
        addHousePhotoButton.isHidden = true
        self.housePosterView.image = image
        dismiss(animated: true, completion: nil)
    }
}

extension HouseSignUpViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection. 
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        longitude = String(place.coordinate.longitude)
        latitude = String(place.coordinate.latitude)
        
        self.addressTextField.text = place.formattedAddress
        self.dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
