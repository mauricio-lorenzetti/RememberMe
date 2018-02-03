//
//  Geotification.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 18/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

struct GeotificationKey {
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"
    static let identifier = "identifier"
    static let note = "note"
    static let eventType = "eventType"
    static let items = "items"
}

enum EventType: String {
    case onEntry = "On Entry"
    case onExit = "On Exit"
}

class Geotification: NSObject, NSCoding, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: Int
    var note: String
    var eventType: EventType
    var items: [Item] = []
    var isActive = false
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let radiusString = String(format: "%.01f", radius)
        return "Radius: \(radiusString)m"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: Int, note: String, eventType: EventType, items: [Item]) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.eventType = eventType
        self.items = items
    }
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        let latitude = decoder.decodeDouble(forKey: GeotificationKey.latitude)
        let longitude = decoder.decodeDouble(forKey: GeotificationKey.longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDouble(forKey: GeotificationKey.radius)
        identifier = decoder.decodeInteger(forKey: GeotificationKey.identifier)
        note = decoder.decodeObject(forKey: GeotificationKey.note) as! String
        eventType = EventType(rawValue: decoder.decodeObject(forKey: GeotificationKey.eventType) as! String)!
        items = (decoder.decodeObject(forKey: GeotificationKey.items) as! [Item])
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(coordinate.latitude, forKey: GeotificationKey.latitude)
        coder.encode(coordinate.longitude, forKey: GeotificationKey.longitude)
        coder.encode(radius, forKey: GeotificationKey.radius)
        coder.encode(identifier, forKey: GeotificationKey.identifier)
        coder.encode(note, forKey: GeotificationKey.note)
        coder.encode(eventType.rawValue, forKey: GeotificationKey.eventType)
        coder.encode(items,forKey:GeotificationKey.items)
    }
    
}
