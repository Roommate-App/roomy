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
    @IBOutlet weak var mapView: MKMapView!
    
    var region: CLCircularRegion!
    var roomies: [Roomy]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        let title = "Home"
        
        let coordinate = CLLocationCoordinate2D(latitude: Double((House._currentHouse?.latitude)!)!, longitude: Double((House._currentHouse?.longitude)!)!)
        let regionRadius = 100.0
        
        region = CLCircularRegion(center: coordinate, radius: regionRadius, identifier: title)
        locationManager.startMonitoring(for: region)
        
        let circle = MKCircle(center: coordinate, radius: regionRadius)
        mapView.add(circle)
        getRoomies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getRoomies(){
        for roomy in (House._currentHouse?.userIDs)! {
            roomy.fetchInBackground(block: { (userReturned: PFObject?, error: Error?) in
                if userReturned != nil {
                    self.roomies?.append(userReturned as! Roomy)
                } else {
                    print("HomeTimelineViewController/ViewDidLoad() \(String(describing: error?.localizedDescription))")
                }
                self.isHome()
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
        cell.roomyNameLabel.text = roomy?["username"] as? String
        
        let home = roomy?["is_home"] as? Bool
        if(home)!{
            cell.isRoomyHomeControl.selectedSegmentIndex = 0
        } else {
            cell.isRoomyHomeControl.selectedSegmentIndex = 1
        }
        return cell
    }
    
    //MARK: - LocationManager FUNCTIONS
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let mapRegion = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(mapRegion, animated: true)
        mapView.showsUserLocation = true
        Roomy.current()?["longitude"] = location.coordinate.longitude
        Roomy.current()?.saveInBackground()
        
        if UIApplication.shared.applicationState == .active{
            print(location)
        } else if(_isBackground) {
            self.locationManager.allowDeferredLocationUpdates(untilTraveled: CLLocationDistanceMax, timeout: 1800)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User is home")
        Roomy.current()?["is_home"] = true
        Roomy.current()?.saveInBackground()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("User is not home")
        Roomy.current()?["is_home"] = false
        Roomy.current()?.saveInBackground()
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        Roomy.current()?["test"] = manager.location?.coordinate.latitude
        Roomy.current()?.saveInBackground()
        print("test")
    }

    //MARK: - MAPVIEW FUNCTIONS
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
    func isHome(){
        let home = region.contains((locationManager.location?.coordinate)!)
        Roomy.current()?["is_home"] = home
        Roomy.current()?.saveInBackground()
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
