//
//  HouseSignUpViewController.swift
//  roomy
//
//  Created by Poojan Dave on 3/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import GooglePlaces

// Make sure only unique houseIDs are created (especially addresses)


// HouseSignUpViewController: Creates a new house
class HouseSignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var houseIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let autocompleteController = GMSAutocompleteViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressTextField.delegate = self
        houseIDTextField.delegate = self
        passwordTextField.delegate = self
        
        autocompleteController.delegate = self
    }

    @IBAction func didTouchAddressTextField(_ sender: Any) {
        present(autocompleteController, animated: true, completion: nil)
    }
    
    // signUpButtonPressed Action: creates new house
    // Extracts the address, houseID, and password
    // array of "userIDs" is set to currentUser
    // Create a newHouse of type PFObject and input appropriate keys for the object
    // Save the object is background and then set the currentHouse and segue
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        // Extracting the proper values
        let address = addressTextField.text!
        let houseID = houseIDTextField.text!
        let password = passwordTextField.text!
        
        // create newHouse as a PFObject; class House
        let newHouse = PFObject(className: "House")
        
        // save the address, houseID, and password as keys
        newHouse["address"] = address
        newHouse["houseID"] = houseID
        newHouse["password"] = password
        
        // Set the userIDs to currentUser
        newHouse["userIDs"] = [PFUser.current()]
        
        // save in background; save to Parse
        newHouse.saveInBackground { (success: Bool, error: Error?) in
            
            if success {
                
                // set currentUser "HouseID" to currentHouse
                PFUser.current()?["house"] = newHouse
                // Save to Parse
                PFUser.current()?.saveInBackground()
                
                //set the current house
                House.setCurrentHouse(house: newHouse)
                
                self.performSegue(withIdentifier: "houseSignUpToTabBar", sender: nil)
            }

        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension HouseSignUpViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection. 
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        print("Place address: \(place.coordinate)") // // // For Ryan's use // // //
        
        self.addressTextField.text = place.formattedAddress
        self.houseIDTextField.becomeFirstResponder()
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
