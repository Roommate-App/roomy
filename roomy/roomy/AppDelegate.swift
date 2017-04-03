//
//  AppDelegate.swift
//  roomy
//
//  Created by Poojan Dave on 3/13/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

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
        
        
        // reference the storyboard
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // reference the 3 possible starting viewControllers using their Storyboard IDs
        let userLoginViewController = mainStoryboard.instantiateViewController(withIdentifier: "UserLoginViewController") as! UserLoginViewController
        let houseLoginViewController = mainStoryboard.instantiateViewController(withIdentifier: "HouseLoginViewController") as! HouseLoginViewController
        let tabBar = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController")
        
        
        // Determining which ViewController should be the first one
        // Checking to see if currentUser is logged in
        if PFUser.current() != nil {
            
            print("There is a current user.")
            
            // REMEMBER to cast as PFObject
            let currentHouse = PFUser.current()?["house"] as? PFObject
            
            // Checking to see if the user has a "house"
            if currentHouse != nil {
                
                print("There is a HouseID")
                
                // Fetching the house
                currentHouse?.fetchInBackground(block: { (houseReturned: PFObject?, error: Error?) in
                    
                    if houseReturned != nil {
                        
                        House.setCurrentHouse(house: currentHouse!)
                        
                        // User and House exists, so tabBar will be the first viewController
                        self.window?.rootViewController = tabBar
                        
                    } else {

                        print("AppDelegate/RetrievingHouse Error:  \(String(describing: error?.localizedDescription))")
                    }
                })

            // No house ID exits
            } else {
                
                print("No HouseID exists")
                
                // User exists but HouseID doesn't, so start at the HouseLogin
                window?.rootViewController = houseLoginViewController
            }
            
        // No user exists
        } else {
            
            print("No user exists")
            
            // No user exists, so loginViewController will be first viewController
            window?.rootViewController = userLoginViewController
        }
        
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

