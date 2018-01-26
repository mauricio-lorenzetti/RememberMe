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

class MapViewController: UIViewController {

    let itemCellReuseIdentifier = "itemCell"
    
    var selectedItems: [Item]?
    var minimumRadius = 25.0
    var radius: Double = 100.0 {
        willSet(changedValue) {
            if (abs(radius - changedValue) >= 1 ) {
                drawOverlayCircle()
            }
        }
    }
    var circleOverlay: MKCircle?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var selectedItemsGrid: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.zoomToUserLocation()
        
        selectedItemsGrid.delegate = self
        selectedItemsGrid.dataSource = self
        
        drawOverlayCircle()
    }
    
    @IBAction func doneRemainderTapped(_ sender: UIButton) {
        
        let center = mapView.centerCoordinate
        
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC") as! ViewController
        
        VC.isHeroEnabled = true
        
        VC.heroModalAnimationType = .zoomSlide(direction: .down)
        
        //Saves new card
        VC.geotifications.append(Geotification(coordinate: center, radius: radius, identifier: "id", note: "note", eventType: .onExit, items: selectedItems!))
        
        //Register new location notification
        let nc:UNUserNotificationCenter = UNUserNotificationCenter.current()
        let nopt:UNAuthorizationOptions = [.sound, .alert]
        
        nc.requestAuthorization(options: nopt) { (granted, e) in
            if let e = e {
                print(e.localizedDescription)
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Hey!! Don't forget these things:"
        content.body = ((selectedItems?.map{ String(describing: $0.iconTitle) })?.joined(separator: ", "))!
        
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        
        let request = UNNotificationRequest(identifier: "RememberMe", content: content, trigger: trigger)
        nc.add(request) { (e) in
            if let err = e {
                print(err.localizedDescription)
            }
        }
        
        self.hero_replaceViewController(with: VC)
        
    }
    
    @IBAction func radiusSliderChanged(_ sender: UISlider) {
        radius = Double(pow(5.0, radiusSlider.value))*minimumRadius //logaritmic scale
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
        
        let cellGrid = collectionView.dequeueReusableCell(withReuseIdentifier: itemCellReuseIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        cellGrid.itemImage.image = UIImage(named: selectedItems![indexPath.row].iconTitle)
        
        return cellGrid
            
    }
}
