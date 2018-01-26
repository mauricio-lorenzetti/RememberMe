//
//  ItemsViewController.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 22/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import UIKit
import Hero

class ItemsViewController: UIViewController {

    @IBOutlet weak var itemsCard: UIView!
    @IBOutlet weak var itemsGrid: UICollectionView!
    @IBOutlet weak var selectedItemsGrid: UICollectionView!
    
    let itemCellReuseIdentifier = "itemCell"
    
    var selectedItems:[Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHeroEnabled = true
        
        itemsCard.heroID = "itemsCard"
        itemsCard.heroModifiers = [.cascade, .fade]
        
    }

    @IBAction func setRemainderTapped(_ sender: UIButton) {
        
        let mapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapVC") as! MapViewController
        
        mapVC.isHeroEnabled = true
        
        mapVC.heroModalAnimationType = .zoomSlide(direction: .up)
        
        mapVC.selectedItems = selectedItems
        
        self.hero_replaceViewController(with: mapVC)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ItemsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case itemsGrid:
            return ItemsDB.allObjects.count
        case selectedItemsGrid:
            return selectedItems.count
        default:
            fatalError()
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellGrid = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellReuseIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        switch collectionView {
        case itemsGrid:
            cellGrid.itemImage.image = UIImage(named: ItemsDB.allObjects[indexPath.row].iconTitle)
        case selectedItemsGrid:
            cellGrid.itemImage.image = UIImage(named: selectedItems[indexPath.row].iconTitle)
        default:
            fatalError()
        }
        
        return cellGrid
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedItems.append(ItemsDB.allObjects[indexPath.row])
        selectedItemsGrid.reloadData()
        
    }
    
}

