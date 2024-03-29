//
//  ViewController.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 15/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import UIKit
import FoldingCell
import Hero
import MapKit
import CoreLocation
import UserNotifications

fileprivate struct C {
    struct CellHeight {
        static let close: CGFloat = 160.0 // equal or greater foregroundView height
        static let open: CGFloat = 385.0 // equal or greater containerView height
    }
}

class ViewController: UIViewController {
    
    let cardReuseIdentifier = "geotification_cell"
    let newGeotificationReuseIdentifier = "button_cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var geotifications = [Geotification]()
    var cellHeights:[CGFloat]?
    var mapView:MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        geotifications = loadAllGeotifications()
        
        cellHeights = (0..<geotifications.count + 1).map { _ in C.CellHeight.close }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        let nc = UNUserNotificationCenter.current()
        let nopt:UNAuthorizationOptions = [.sound, .alert]
        nc.requestAuthorization(options: nopt) { (granted, e) in
            if let e = e {
                print(e.localizedDescription)
            }
        }
        
        mapView = MKMapView()
        mapView?.delegate = self
        mapView?.showsUserLocation = true
        mapView?.setUserTrackingMode(.follow, animated: false)
        
    }
    
    @IBAction func newRemainderTapped(_ sender: UIButton) {
        
        let itemsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemsVC") as! ItemsViewController
        
        itemsVC.isHeroEnabled = true
        itemsVC.heroModalAnimationType = .fade
        self.hero_replaceViewController(with: itemsVC)
        
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return geotifications.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < geotifications.count {
            
            let g = geotifications[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cardReuseIdentifier, for: indexPath) as! RemainderCell
            
            //cell card design
            
            
            //cell collection views
            cell.items = g.items
            
            cell.itemsCollectionView.dataSource = cell
            cell.itemsCollectionView.reloadData()
            
            cell.openItemsCollectionView.dataSource = cell
            cell.openItemsCollectionView.reloadData()
            
            cell.titleLabel.text = g.note
            cell.openColorLabelView.text = g.note
            
            if g.isActive {
                cell.colorViewWidth.constant = 40.0
            } else {
                cell.colorViewWidth.constant = 15.0
            }
            
            //generating map snapshot
            let mapSnapshotOptions = MKMapSnapshotOptions()
            
            // Set the region of the map that is rendered.
            let dY = g.radius*2
            let dX = dY * (360/191)
            let region = MKCoordinateRegionMakeWithDistance(g.coordinate, dX, dY)
            mapSnapshotOptions.region = region
            
            // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
            mapSnapshotOptions.scale = UIScreen.main.scale
            
            // Set the size of the image output.
            mapSnapshotOptions.size = CGSize(width: 360, height: 191)
            
            // Show buildings and Points of Interest on the snapshot
            mapSnapshotOptions.showsBuildings = true
            mapSnapshotOptions.showsPointsOfInterest = true
            
            let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
            
            snapShotter.start(completionHandler: { (snapshot, error) in
                
                let image = (snapshot?.image)!
                let center = snapshot?.point(for: g.coordinate)
                let border = snapshot?.point(for: CLLocationCoordinate2D(latitude: g.coordinate.latitude, longitude: g.coordinate.longitude + g.radius/111111)) //111,111m equivale a +/- 1 grau
                let rad = self.distance(center!, border!)
                
                UIGraphicsBeginImageContext(image.size)
                image.draw(at: .zero)
                let context = UIGraphicsGetCurrentContext()
                context?.setLineWidth(3.0)
                context?.setFillColor(UIColor(red: 227/255.0, green: 255/255.0, blue: 2/255.0, alpha: 0.4).cgColor)
                context?.setStrokeColor(UIColor(red: 227/255.0, green: 255/255.0, blue: 2/255.0, alpha: 1).cgColor)
                context?.addArc(center: center!, radius: CGFloat(rad), startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: false)
                context?.strokePath()
                context?.addArc(center: center!, radius: CGFloat(rad), startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: false)
                context?.fillPath()
                let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                cell.locationImageView.image = finalImage
            })
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: newGeotificationReuseIdentifier, for: indexPath)
            
            return cell
        }
    }
    
    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row < geotifications.count {
            return .delete
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let g = geotifications[indexPath.row]
            locationManager.stopMonitoring(for:
                CLCircularRegion(
                    center: g.coordinate,
                    radius: g.radius,
                    identifier: String(describing: g.identifier)))
            geotifications.remove(at: indexPath.row)
            saveAllGeotifications(geotifications: geotifications)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights![indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let cell as FoldingCell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        var duration = 0.0
        if cellHeights![indexPath.row] == C.CellHeight.close { // open cell
            cellHeights![indexPath.row] = C.CellHeight.open
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights![indexPath.row] = C.CellHeight.close
            cell.unfold(false, animated: true, completion: nil)
            duration = 1.1
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if case let cell as FoldingCell = cell {
            if cellHeights![indexPath.row] == C.CellHeight.close {
                cell.unfold(false, animated: false, completion:nil)
            } else {
                cell.unfold(true, animated: false, completion: nil)
            }
        }
    }
    
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        _ = geotifications.map {
            let distanceFrom = MKMetersBetweenMapPoints(MKMapPointForCoordinate($0.coordinate), MKMapPointForCoordinate(mapView.userLocation.coordinate))
            
            if  (distanceFrom <= $0.radius && $0.isActive == false) {
                $0.isActive = true
                tableView.reloadData()
            } else if (distanceFrom > $0.radius && $0.isActive == true) {
                $0.isActive = false
                tableView.reloadData()
            }
        }
        geotifications.sort { (a, b) -> Bool in
            return a.isActive
        }
    }
    
}

