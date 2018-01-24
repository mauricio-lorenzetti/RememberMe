//
//  ViewController.swift
//  RememberMe
//
//  Created by Mauricio Lorenzetti Bezerra on 15/01/18.
//  Copyright © 2018 Mauricio Lorenzetti Bezerra. All rights reserved.
//

import UIKit
import FoldingCell
//import fluid_slider
import Hero
import MapKit
import CoreLocation
import UserNotifications

fileprivate struct C {
    struct CellHeight {
        static let close: CGFloat = 160.0 // equal or greater foregroundView height
        static let open: CGFloat = 450.0 // equal or greater containerView height
    }
}

class ViewController: UIViewController {
    
    let nc:UNUserNotificationCenter = UNUserNotificationCenter.current()
    let nopt:UNAuthorizationOptions = [.sound, .alert]
    
    let reuseIdentifier = "geotification_cell"
    let newRegionReuseIdentifier = "button_cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var geotifications = [Geotification]()
    var cellHeights:[CGFloat]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadAllGeotifications()
        
        cellHeights = (0..<geotifications.count+1).map { _ in C.CellHeight.close }
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
        
        //Notification
        nc.requestAuthorization(options: nopt) { (granted, e) in
            print("autorizou? \(granted)")
            if let e = e {
                print(e.localizedDescription)
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "don't forget"
        content.body = "your own shit"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: "remember", content: content, trigger: trigger)
        nc.add(request) { (e) in
            if let err = e {
                print(err.localizedDescription)
            }
        }
        
        geotifications.map {
            let region = CLCircularRegion(center: $0.coordinate, radius: $0.radius, identifier: $0.identifier)
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
        }
        
    }
    
    @IBAction func newRemainderTapped(_ sender: UIButton) {
        
        let itemsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemsVC") as! ItemsViewController
        
        itemsVC.isHeroEnabled = true
        
        itemsVC.heroModalAnimationType = .zoomSlide(direction: .up)
        
        self.hero_replaceViewController(with: itemsVC)
        
    }
    
    private func loadAllGeotifications() {
        geotifications = []
        geotifications.append(createDefaultGeotification())
    }
    
    private func createDefaultGeotification() -> Geotification {
        return Geotification(
            coordinate: CLLocationCoordinate2D.init(latitude: -22.812749, longitude: -47.065614),
            radius: 100.0,
            identifier: "#0",
            note: "default",
            eventType: .onExit,
            items: [Item.init(iconTitle: "cat")])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return geotifications.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row >= geotifications.count ? newRegionReuseIdentifier : reuseIdentifier, for: indexPath)
        
        //TODO: preencher a celula 
        
        return cell
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


