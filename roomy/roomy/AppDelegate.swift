//
//  AppDelegate.swift
//  roomy
//
//  Created by Poojan Dave on 3/13/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

    // First method that is called when the program runs
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Setting up Parse with keys
        Parse.initialize(
            with: ParseClientConfiguration(block: { (configuration:ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "roomy "
                configuration.clientKey = "fdslajkflnjwqleiuwtrwt47857qyrehwaufw293rj89rfncnal"
                configuration.server = "https://floating-oasis-68386.herokuapp.com/parse"
            })
        )
        
        if PFUser.current() != nil {
            
            print("There is a current user.")
            let currentHouse = PFUser.current()?["house"] as? PFObject

            if currentHouse != nil {
                
                print("There is a HouseID")
                currentHouse?.fetchInBackground(block: { (houseReturned: PFObject?, error: Error?) in
                    
                    if houseReturned != nil {
                        House.setCurrentHouse(house: currentHouse!)
                        
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
        
        
        // Google Places API
        GMSPlacesClient.provideAPIKey("AIzaSyCeA-ugIfZ4hA1WpRuobEFMM8GciAYy6-o")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

