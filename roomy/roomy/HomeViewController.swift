//
//  HomeViewController.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/4/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import MapKit

class HomeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    let locationManager = CLLocationManager()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var region: CLCircularRegion!
    var roomies: [Roomy]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        LocationService.shared.setUpHouseFence()
        LocationService.shared.isRoomyHome()
        getRoomies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        LocationService.shared.isRoomyHome()
        for roomy in roomies! {
            roomy.fetchInBackground()
        }
        collectionView.reloadData()
    }
    
    func getRoomies(){
        for roomy in (House._currentHouse?.userIDs)! {
            roomy.fetchInBackground(block: { (userReturned: PFObject?, error: Error?) in
                if userReturned != nil {
                    self.roomies?.append(userReturned as! Roomy)
                } else {
                    print("HomeTimelineViewController/ViewDidLoad() \(String(describing: error?.localizedDescription))")
                }
                //self.isHome()
                self.collectionView.reloadData()
            })
        }
    }
    
    //Logout button for test purposeses.
    @IBAction func onLogoutButtonTapped(_ sender: Any) {
        
        PFUser.logOutInBackground { (error: Error?) in
            if error == nil {
                House._currentHouse = nil
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "UserLoginViewController") as! UserLoginViewController
                self.present(loginViewController, animated: true, completion: nil)
            }
        }
    }

    //MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if roomies == nil {
            return 0
        } else {
            return roomies!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomyCell", for: indexPath) as! RoomyCollectionViewCell
        
        let roomy = roomies?[indexPath.row]
        cell.roomyNameLabel.text = roomy?.username
        
        let home = roomy?["is_home"] as? Bool ?? true
        if(home){
            cell.isRoomyHomeControl.selectedSegmentIndex = 0
        } else {
            cell.isRoomyHomeControl.selectedSegmentIndex = 1
        }
        return cell
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
