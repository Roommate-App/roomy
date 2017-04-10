//
//  AppDelegate.swift
//  roomy
//
//  Created by Poojan Dave on 3/13/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import MapKit
import GooglePlaces

var _isBackground: Bool = false

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    
    lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        return manager
    }()
    
    
    // First method that is called when the program runs
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        if(launchOptions?[UIApplicationLaunchOptionsKey.location] != nil){
            locationManager.stopMonitoringSignificantLocationChanges()
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.startUpdatingLocation()
        }
        
        Parse.initialize(
            with: ParseClientConfiguration(block: { (configuration:ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "roomy "
                configuration.clientKey = "fdslajkflnjwqleiuwtrwt47857qyrehwaufw293rj89rfncnal"
                configuration.server = "https://floating-oasis-68386.herokuapp.com/parse"
            })
        )

        if Roomy.current() != nil {
            print("There is a current user.")
            let currentHouse = Roomy.current()?["house"] as? House
            
            if currentHouse != nil {
                print("There is a HouseID")
                currentHouse?.fetchInBackground(block: { (house: PFObject?, error: Error?) in
                    
                    if house != nil {
                        
                        House.setCurrentHouse(house: house as! House)
                        
                        let homeStoryBoard = UIStoryboard(name: "TabBar", bundle: nil)
                        let tabBar = homeStoryBoard.instantiateViewController(withIdentifier: "TabBarController")
                        
                        self.window?.rootViewController = tabBar
                        self.window?.makeKeyAndVisible()
                    } else {
                        print("AppDelegate/RetrievingHouse Error:  \(String(describing: error?.localizedDescription))")
                    }
                })
                } else {
                print("No HouseID exists")
                let houseLoginViewController = mainStoryboard.instantiateViewController(withIdentifier: "HouseLoginViewController") as! HouseLoginViewController
                window?.rootViewController = houseLoginViewController
            }
        // No user exists
        } else {
            print("No user exists")
            
            let userLoginViewController = mainStoryboard.instantiateViewController(withIdentifier: "UserLoginViewController") as! UserLoginViewController
            window?.rootViewController = userLoginViewController
            window?.makeKeyAndVisible()
        }
        
        configureParse()

        
        // Google Places API
        GMSPlacesClient.provideAPIKey("AIzaSyCeA-ugIfZ4hA1WpRuobEFMM8GciAYy6-o")
        
        
        return true
    }
    
    func configureParse() {
        House.registerSubclass()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
//        print("app is going to close")
//        locationManager.stopUpdatingLocation()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.distanceFilter = kCLDistanceFilterNone
//        locationManager.pausesLocationUpdatesAutomatically = false
//        locationManager.activityType = CLActivityType.fitness
//        locationManager.startMonitoringSignificantLocationChanges()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        PFUser.current()?["latitude"] = location.coordinate.latitude
        PFUser.current()?.saveInBackground()
        self.locationManager.allowDeferredLocationUpdates(untilTraveled: CLLocationDistanceMax, timeout: 10)
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        PFUser.current()?["test"] = manager.location?.coordinate.latitude
        PFUser.current()?.saveInBackground()
    }
}

