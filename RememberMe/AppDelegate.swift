//
//  AppDelegate.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 15/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

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
        
        let selectedItems = loadAllGeotifications().filter { String(describing: $0.identifier) == region.identifier }[0].items
        
        //Register new location notification
        let nc:UNUserNotificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Hey!! Don't forget these things:"
        content.body = selectedItems.map{ String(describing: $0.iconTitle) }.joined(separator: ", ")
        let request = UNNotificationRequest(identifier: region.identifier, content: content, trigger: nil)
        nc.add(request) { (e) in
            if let err = e {
                print(err.localizedDescription)
            }
        }
        
    }

}

extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        handleEvent(forRegion: region)
    }
    
}

