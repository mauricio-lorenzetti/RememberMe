//
//  MeFoldingCell.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 16/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import UIKit
import FoldingCell

class RemainderCell: FoldingCell {
    
    //Closed variables
    @IBOutlet weak var colorViewWidth: NSLayoutConstraint!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    //Expanded variables
    @IBOutlet weak var openColorView: UIView!
    @IBOutlet weak var openColorLabelView: UILabel!
    @IBOutlet weak var openItemsCollectionView: UICollectionView!
    @IBOutlet weak var locationImageView: UIImageView!
    
    //Aux variables
    var items:[Item] = []
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        foregroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        foregroundView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        foregroundView.layer.shadowOpacity = 0.7
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        // durations count equal it itemCount
        let durations = [0.55, 0.27] // timing animation for each view
        return durations[itemIndex]
    }

}

extension RemainderCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName:"ItemCVCell", bundle: nil), forCellWithReuseIdentifier: PreferencesKeys.itemCellIdentifier)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreferencesKeys.itemCellIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        cell.itemImage.image = UIImage(named: items[indexPath.row].iconTitle)
        
        return cell
        
    }
    
    
}
