//
//  HomeTimelineViewController.swift
//  roomy
//
//  Created by Poojan Dave on 3/18/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

class HomeTimelineViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var houseIDLabel: UILabel!
    @IBOutlet weak var HouseAddressLabel: UILabel!
    @IBOutlet weak var roomiesCountLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentHouse = House._currentHouse!
        
        print(PFUser.current()!)
        
        print(currentHouse)
        print(currentHouse.address!)
        print(currentHouse.houseID!)
        print(currentHouse.password!)
        print(currentHouse.userIDs!)
        
        houseIDLabel.text = currentHouse.houseID
        HouseAddressLabel.text = currentHouse.address
        roomiesCountLabel.text = "Number of roomies: \(String(describing: currentHouse.userIDs!.count))"
        
        for user in (House._currentHouse?.userIDs)! {
            user.fetchInBackground(block: { (userReturned: PFObject?, error: Error?) in
                if userReturned != nil {
                    print(userReturned!)
                } else {
                    print("HomeTimelineViewController/ViewDidLoad() \(String(describing: error?.localizedDescription))")
                }
            })
        }
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

    }
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        PFUser.logOutInBackground { (error: Error?) in
            if error == nil {
                House._currentHouse = nil
                
                self.performSegue(withIdentifier: "homeTimelineToUserLogin", sender: nil)
            }
        }
        
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        if status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            PFUser.current()?["latitude"] = Double((locationManager.location?.coordinate.latitude)!)
            PFUser.current()?["longitude"] = Double((locationManager.location?.coordinate.longitude)!)
            PFUser.current()?.saveInBackground()
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
