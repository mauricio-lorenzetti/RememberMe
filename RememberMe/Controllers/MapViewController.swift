//
//  MapViewController.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 22/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import fluid_slider

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var selectedItemsGrid: UICollectionView!
    @IBOutlet weak var radiusSlider: Slider!
    
    let locationManager = CLLocationManager()
    
    var selectedItems: [Item]?
    var minimumRadius = 25.0
    var radius: Double = 55.0 {
        willSet(changedValue) {
            if (abs(radius - changedValue) >= 1 ) {
                drawOverlayCircle()
            }
        }
    }
    var circleOverlay: MKCircle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.zoomToUserLocation()
        
        selectedItemsGrid.delegate = self
        selectedItemsGrid.dataSource = self
        
        let sliderTextAttributes: [NSAttributedStringKey : Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.white]
        radiusSlider.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 3
            formatter.minimumIntegerDigits = 3
            formatter.maximumFractionDigits = 0
            let string = formatter.string(from: self.radius as NSNumber) ?? ""
            return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor.black])
        }
        radiusSlider.setMaximumLabelAttributedText(NSAttributedString(string: "125", attributes: sliderTextAttributes))
        radiusSlider.setMinimumLabelAttributedText(NSAttributedString(string: "25", attributes: sliderTextAttributes))
        radiusSlider.fraction = 0.5
        radiusSlider.shadowOffset = CGSize(width: 0, height: 10)
        radiusSlider.shadowBlur = 5
        radiusSlider.shadowColor = UIColor(white: 0, alpha: 0.1)
        //TODO: cores
        radiusSlider.contentViewColor = UIColor(red: 78/255.0, green: 77/255.0, blue: 224/255.0, alpha: 1)
        radiusSlider.valueViewColor = .white
        
        radiusSlider.addTarget(self, action: #selector(radiusSliderChanged), for: .valueChanged)
        
        radiusSliderChanged()
        drawOverlayCircle()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        
        let itemsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemsVC") as! ItemsViewController
        
        itemsVC.isHeroEnabled = true
        itemsVC.heroModalAnimationType = .zoomSlide(direction: .up)
        
        itemsVC.selectedItems = selectedItems!
        
        self.hero_replaceViewController(with: itemsVC)
        
    }
    
    @IBAction func doneRemainderTapped(_ sender: UIButton) {
        
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC") as! ViewController
        
        VC.isHeroEnabled = true
        VC.heroModalAnimationType = .zoomSlide(direction: .down)
        
        //Saves new card
        VC.geotifications = loadAllGeotifications()
        let center = mapView.centerCoordinate
        let g = Geotification(coordinate: center,
                              radius: radius,
                              identifier: VC.geotifications.uniqueIdentifier(),
                              note: "note",
                              eventType: .onExit,
                              items: selectedItems!)
        VC.geotifications.append(g)
        saveAllGeotifications(geotifications: VC.geotifications)
        
        //Register notification for geotification
        let region = CLCircularRegion(
            center: g.coordinate,
            radius: g.radius,
            identifier: String(describing: g.identifier))
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
        
        self.hero_replaceViewController(with: VC)
        
    }
    
    @objc func radiusSliderChanged() {
        radius = Double(pow(5.0, radiusSlider.fraction))*minimumRadius //logaritmic scale
    }
    
    func drawOverlayCircle() {
        self.mapView.removeOverlays(self.mapView.overlays)
        circleOverlay = MKCircle(center: mapView.centerCoordinate, radius: radius)
        self.mapView.add(circleOverlay!)
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple 
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        drawOverlayCircle()
    }
    
}

extension MapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (selectedItems?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName:"ItemCVCell", bundle: nil), forCellWithReuseIdentifier: PreferencesKeys.itemCellIdentifier)
        
        let cellGrid = collectionView.dequeueReusableCell(withReuseIdentifier: PreferencesKeys.itemCellIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        cellGrid.itemImage.image = UIImage(named: selectedItems![indexPath.row].iconTitle)
        
        return cellGrid
            
    }
}
