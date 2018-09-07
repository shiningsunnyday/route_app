//
//  HomeViewController.swift
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

class HomeViewController: UIViewController {

    var mapView: GMSMapView?
    var marker: GMSMarker?
    var latitude: Double = 0
    var longitude: Double = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        marker?.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker?.title = "Current"
        marker?.snippet = "Location"

        if let mapV = self.mapView, let markerV = self.marker {
            
            markerV.map = mapV
            view = mapV
            
        }
        
    }
    
}

