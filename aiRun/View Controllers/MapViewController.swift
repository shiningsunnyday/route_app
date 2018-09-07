//
//  MapViewController.swift
//  aiRun
//
//  Created by Michael Sun on 7/19/18.
//  Copyright © 2018 Michael Sun and Eric Frankel. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import Alamofire
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class MapViewController: UIViewController, MGLMapViewDelegate {
    
    var mapView: NavigationMapView!
    var directionsRoute: Route?
    
    var distance: Double = 0
    var boo = true
    var time: Double = 0
    var curLocation = CLLocation() { didSet {
        
        let camera = GMSCameraPosition.camera(withLatitude: curLocation.coordinate.latitude, longitude: curLocation.coordinate.longitude, zoom: 14)
        if boo { mapView.animate(to: camera) }
        boo = false
        marker.map = nil
        marker = GMSMarker(position: curLocation.coordinate)
        marker.icon = UIImage(named: "runman.png")
        marker.title = "Current"
        marker.snippet = "Location"
        marker.map = mapView
        view = mapView
        
        }}
    var locationManager = CLLocationManager()
    var marker = GMSMarker()
    var path = GMSMutablePath()
    var coordinates: [CLLocationCoordinate2D] = [] {
        didSet {
            
            print("YES")
            print(coordinates.last)
            path.add(coordinates.last!)
            
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        /*print("Location gotten: \(curLocation.coordinate)")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
            
                
            var str: String = "https://runningapp-api-heroku.herokuapp.com/data/?lat=\(Double(curLocation.coordinate.latitude))&lng=\(Double(curLocation.coordinate.longitude))&dist=\(self.distance)"
            Alamofire.request(str).responseJSON { response in
                
                if let data = response.data {
                    
                    let listOfCoordinates: [Coordinate]? = try? JSONDecoder().decode([Coordinate].self, from: data)
                    if let list = listOfCoordinates {
                        print(list)
                        for index in 0...(list.count-1) {
                            
                            self.coordinates.append(CLLocationCoordinate2D(latitude: list[index].lat, longitude: list[index].lng))
                            
                        }
                        
                        print(self.coordinates)
                        let polyline = GMSPolyline(path: self.path)
                        polyline.strokeWidth = 5
                        polyline.map = self.mapView
                        self.view = self.mapView
                        
                    }
                
                
            }
                
            
            
            
        
            
        }
        */
        mapView = NavigationMapView(frame: view.bounds)
        
        view.addSubview(mapView)
        
        // Set the map view's delegate
        mapView.delegate = self
        
        
        //GET ALL THE COORDINATES HERE AND APPEND TO COORDINATES
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
    
    


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            
            curLocation = location
            
        }
        
    }
}



