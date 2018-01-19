//
//  AppDelegate.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 15/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        locationManager.delegate = self
        return true
    }
    
    func handleEvent(forRegion region: CLRegion) {
        print(region.identifier)
    }

}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        handleEvent(forRegion: region)
    }
    
}

