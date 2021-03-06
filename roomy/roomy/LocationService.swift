//
//  LocationService.swift
//  roomy
//
//  Created by Ryan Liszewski on 4/9/17.
//  Copyright © 2017 Poojan Dave. All rights reserved.
//

import UIKit
import CoreLocation



class LocationService: NSObject, CLLocationManagerDelegate  {
    
    static let shared = LocationService()
    var locationManager = CLLocationManager()
    var region: CLCircularRegion!
	
	func requestLocationAuthorization(){
	}
    
    func startUpdatingLocation(){
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
  
    //Set's up house geofence
    func setUpHouseFence(){
        startUpdatingLocation()
        let title = "Home"
        let coordinate = CLLocationCoordinate2D(latitude: Double((House._currentHouse?.latitude)!)!, longitude: Double((House._currentHouse?.longitude)!)!)
        let regionRadius = 300.0
        region = CLCircularRegion(center: coordinate, radius: regionRadius, identifier: title)
        locationManager.startMonitoring(for: region)
    }
    
    func isRoomyHome(){
        if let currentLocation = locationManager.location?.coordinate {
            let isHome = region.contains(currentLocation)
            Roomy.current()?["is_home"] = isHome

            do {
                try Roomy.current()?.save()
            }
            catch let error as Error?{
                    print(error!.localizedDescription)
            }
        }
    }
    
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
    }
    
    func restartUpdatingLocation(){
        locationManager.stopMonitoringSignificantLocationChanges()
        startUpdatingLocation()
    }
    
    func startMonitoringLocation(){
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		let location = locations[0]
    }
    
    //MARK: Location Manager region monitoring functions
 }


