//
//  HomeMapViewController.swift
//  aiRun
//
//  Created by Michael Sun on 7/20/18.
//  Copyright © 2018 Michael Sun and Eric Frankel. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import Alamofire

class HomeMapViewController: UIViewController  {
    
    var locationManager = CLLocationManager()
    var delegate: LocationDelegate?
    var mapView = GMSMapView()
    var marker = GMSMarker()
    var camera: GMSCameraPosition?
    var curLocation = CLLocation() { didSet {
    
        
        var current = GMSCameraPosition.camera(withLatitude: curLocation.coordinate.latitude + 0.007,
                                              longitude: curLocation.coordinate.longitude - 0.008,
                                              zoom: 15)
        mapView.camera = current
        marker.map = mapView
        
        
        view = mapView
        
        self.delegate?.locationReady(location: curLocation)
        
        }}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        //GET ALL THE COORDINATES HERE AND APPEND TO COORDINATES
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




extension HomeMapViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
            mapView.isMyLocationEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            curLocation = location
            /*coordinates.append(location.coordinate)*/
            /*let camera = GMSCameraPosition.camera(withLatitude: coordinates.first!.latitude, longitude: coordinates.first!.longitude, zoom: 10.0)
             
             mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
             
             view = mapView*/
            
        }
        
    }
}




