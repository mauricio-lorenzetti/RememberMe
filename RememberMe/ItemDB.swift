//
//  ItemDB.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 18/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import Foundation

class ItemsDB: NSObject {
    
    //list of objects that will appear in buttonScreen
    static let allObjects = [ Item(iconTitle: "cat"),
                              Item(iconTitle: "cat"),
                              Item(iconTitle: "cat") ]
    
    static func getItemByIconTitle(title iconTitle: String) -> Item? {
        return allObjects.filter{ $0.iconTitle == iconTitle }[0]
    }
}
