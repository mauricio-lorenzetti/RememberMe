//
//  Utilities.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 18/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import Foundation
import UIKit
import MapKit

struct PreferencesKeys {
    static let savedItems = "savedItems"
    static let itemCellIdentifier = "itemCell"
}

func loadAllGeotifications() -> [Geotification] {
    var geotifications:[Geotification] = []
    guard let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) else { return [] }
    for savedItem in savedItems {
        guard let geotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? Geotification else { continue }
        geotifications.append(geotification)
    }
    return geotifications
}

func saveAllGeotifications(geotifications:[Geotification]) {
    var items: [Data] = []
    for geotification in geotifications {
        let item = NSKeyedArchiver.archivedData(withRootObject: geotification)
        items.append(item)
    }
    UserDefaults.standard.set(items, forKey: PreferencesKeys.savedItems)
}

func createDefaultGeotification() -> Geotification {
    let locationManager = CLLocationManager()
    return Geotification(
        coordinate: (locationManager.location?.coordinate)!,
        radius: 100.0,
        identifier: -1,
        note: "default",
        eventType: .onExit,
        items: [Item(iconTitle: "Cat"),Item(iconTitle: "Dog")])
}

// MARK: Helper Extensions
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        setRegion(region, animated: true)
    }
    
    func zoomToUserLocation(radius: Double) {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, radius, radius)
        setRegion(region, animated: true)
    }
}

extension Array where Iterator.Element == Geotification {
    func uniqueIdentifier() -> Int {
        let identifiers = self.map { $0.identifier }
        var uniqueIdentifier = 0
        while identifiers.contains(uniqueIdentifier) {
            uniqueIdentifier += 1
        }
        return uniqueIdentifier
    }
}

