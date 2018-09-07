//
//  SwipeViewController.swift
//  aiRun
//
//  Created by Michael Sun on 8/19/18.
//  Copyright © 2018 Michael Sun and Eric Frankel. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SwipeViewController: UIViewController {
    
    
    var locationManager = CLLocationManager()
    var boo = false { didSet {
        
        activityIndicator.stopAnimating()
        
        self.performSegue(withIdentifier: "start", sender: nil)
        
        }}

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var curLocation = CLLocation()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        if !boo {
            
            activityIndicator.center = CGPoint(x: self.view.center.x, y: self.view.center.x + 480)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = .whiteLarge
            self.view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
        } else {
            
            self.performSegue(withIdentifier: "start", sender: nil)
            
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }
    
    var offset: CGFloat = 66
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        let bottomOfScreen: CGFloat = scrollView.contentSize.height - view.frame.height + offset
        offset = 0
        scrollView.setContentOffset(CGPoint(x: 0, y: bottomOfScreen), animated: false)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "start":
            
            let destination = segue.destination as! TitleViewController
            destination.lat = curLocation.coordinate.latitude
            destination.long = curLocation.coordinate.longitude
            
        default:
            
            print("hi")
            
        }
        
    }
    
    
    
}





extension SwipeViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            curLocation = location
            boo = true
            /*coordinates.append(location.coordinate)*/
            /*let camera = GMSCameraPosition.camera(withLatitude: coordinates.first!.latitude, longitude: coordinates.first!.longitude, zoom: 10.0)
             
             mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
             
             view = mapView*/
            
        }
        
    }
}
