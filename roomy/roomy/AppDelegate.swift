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
    
    // First method that is called when the program runs
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        LocationService.shared.startUpdatingLocation()
        
        if(launchOptions?[UIApplicationLaunchOptionsKey.location] != nil){
            LocationService.shared.restartUpdatingLocation()
        }
        
        Parse.initialize(
            with: ParseClientConfiguration(block: { (configuration:ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "roomy "
                configuration.clientKey = "fdslajkflnjwqleiuwtrwt47857qyrehwaufw293rj89rfncnal"
                configuration.server = "https://floating-oasis-68386.herokuapp.com/parse"
            })
        )
        
        if(userExist()){
            userHasHouse()
        } else {
            let userLoginViewController = mainStoryboard.instantiateViewController(withIdentifier: "UserLoginViewController") as! UserLoginViewController
            window?.rootViewController = userLoginViewController
            window?.makeKeyAndVisible()
        }
        
        configureParse()
        
        // Google Places API
        GMSPlacesClient.provideAPIKey("AIzaSyCeA-ugIfZ4hA1WpRuobEFMM8GciAYy6-o")
        
        return true
    }
    
    func userExist() -> Bool {
        if(Roomy.current() != nil){
            return true
        }else {
            return false
        }
    }
    
    func userHasHouse() {
        let house = Roomy.current()?["house"] as? House
        
        if house != nil {
            
            do {
                try house?.fetch()
                House.setCurrentHouse(house: house!)
                let homeStoryBoard = UIStoryboard(name: "TabBar", bundle: nil)
                let tabBar = homeStoryBoard.instantiateViewController(withIdentifier: "TabBarController")
                self.window?.rootViewController = tabBar
                self.window?.makeKeyAndVisible()
            } catch let error as Error? {

            }
        } else {
            let houseLoginViewController = mainStoryboard.instantiateViewController(withIdentifier: "HouseLoginViewController") as! HouseLoginViewController
            window?.rootViewController = houseLoginViewController
        }
    }
    
    func configureParse() {
        House.registerSubclass()
        Message.registerSubclass()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits
        LocationService.shared.startMonitoringLocation()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        LocationService.shared.restartUpdatingLocation()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
