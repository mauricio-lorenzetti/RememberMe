//
//  Item.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 18/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import Foundation
import UIKit

struct ItemKey {
    static let iconTitleKey = "iconTitle"
}

class Item: NSObject, NSCoding {
    
    var iconTitle: String
    
    init(iconTitle: String) {
        self.iconTitle = iconTitle
    }
    
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(iconTitle, forKey: ItemKey.iconTitleKey)
        
    }
    
    public convenience required init?(coder aDecoder: NSCoder) {
        
        let x = aDecoder.decodeObject(forKey: ItemKey.iconTitleKey) as! String
        
        self.init(iconTitle: x)
        
    }
    
}

