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
    
    @IBOutlet weak var selectedItemsCollectionView: UICollectionView!
    
    
    let itemCellReuseIdentifier = "itemCell"
    
    var selectedItems:[Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHeroEnabled = true
        
        itemsGrid.delegate = self
        itemsGrid.dataSource = self
        
        selectedItemsCollectionView.delegate = self
        selectedItemsCollectionView.dataSource = self
        
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
        
        if (self.itemsGrid == collectionView){
            return ItemsDB.allObjects.count
        } else if (self.selectedItemsCollectionView == collectionView){
            return selectedItems.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /* mesma célula, collections diferentes.
        Itens para as collectons vêm de arrays diferentes.
         Verfica qual é a collection e preenche corretamente */
        
        
        let cellGrid = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellReuseIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        cellGrid.itemImage.image = UIImage(named: ItemsDB.allObjects[indexPath.row].iconTitle!)
        
        let cellSelected = collectionView.dequeueReusableCell(withReuseIdentifier:  "selectedCell", for: indexPath) as! ItemCollectionViewCell
        
        cellSelected.itemImage.image = UIImage(named: selectedItems[indexPath.row].iconTitle!)
        
        if (self.selectedItemsCollectionView == collectionView){
            return cellSelected
        } else {
            return cellGrid
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedItems.append(ItemsDB.allObjects[indexPath.row])
        print(selectedItems)
        
        self.selectedItemsCollectionView.reloadData()
        
    }
    
}

