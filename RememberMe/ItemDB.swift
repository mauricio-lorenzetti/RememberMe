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
    static let allObjects = [ Item(iconTitle: "Carteira"),
                              Item(iconTitle: "Chave do Carro"),
                              Item(iconTitle: "Relogio"),
                              Item(iconTitle: "Mochila"),
                              Item(iconTitle: "Chave"),
                              Item(iconTitle: "Fones de Ouvido"),
                              Item(iconTitle: "Oculos"),
                              Item(iconTitle: "Mala"),
                              Item(iconTitle: "Computador"),
                              Item(iconTitle: "Guarda Chuva"),
                              Item(iconTitle: "Oculos de Sol"),
                              Item(iconTitle: "Pendrive"),
                              Item(iconTitle: "Bone"),
                              Item(iconTitle: "Camera"),
                              Item(iconTitle: "Cartao de Credito"),
                              Item(iconTitle: "Livro") ]
    
    static func getItemByIconTitle(title iconTitle: String) -> Item? {
        return allObjects.filter{ $0.iconTitle == iconTitle }[0]
    }
}
