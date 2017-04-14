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


// Make sure only unique houseIDs are created (especially addresses)
// HouseSignUpViewController: Creates a new house
class HouseSignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var houseIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var latitude: String?
    var longitude: String?
    
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
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        House.createHouse(address: addressTextField.text!, houseID: houseIDTextField.text!, password: passwordTextField.text!, userIDs: [Roomy.current()!], latitude: latitude!, longitude: longitude!,  successful:  { (_ successful: Bool) in
                print("Successfully created house: in HouseSignUp")
                self.performSegue(withIdentifier: "houseSignUpToTabBar", sender: nil)
            }, failure: { (_ error: Error) in
                print("Error creating house: in HouseSignUp")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HouseSignUpViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection. 
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        longitude = String(place.coordinate.longitude)
        latitude = String(place.coordinate.latitude)
        
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
