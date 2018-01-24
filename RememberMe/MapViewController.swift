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

class MapViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.zoomToUserLocation()
        drawOverlayCircle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //register new geotification model
    }
    
    @IBAction func doneRemainderTapped(_ sender: UIButton) {
        
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC") as! ViewController
        
        VC.isHeroEnabled = true
        
        VC.heroModalAnimationType = .zoomSlide(direction: .down)
        
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
