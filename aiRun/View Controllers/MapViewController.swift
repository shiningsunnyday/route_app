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

class MapViewController: UIViewController, MGLMapViewDelegate, UIGestureRecognizerDelegate {
    
    var mapView: NavigationMapView!
    var directionsRoute: Route?
    var distance: Double = 0.0
    var curLocation = CLLocation()
    var waypoints: [Waypoint] = []
    var bool = true
    var voiceController: CustomVoiceController?
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        
        guard sender.state == .began else { return }
        
        if bool {
        let annotation = MGLPointAnnotation()
        annotation.coordinate = mapView.userLocation!.coordinate
        annotation.title = "I am ready to run!"
        mapView.addAnnotation(annotation)
            
        calculateRoute(from: annotation.coordinate) { (route, error) in
            
            
            if error != nil {
                print("Error calculating route")
            }
        }
        bool = false
        }
        
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        let navigationViewController = NavigationViewController(for: directionsRoute!)
        
        navigationViewController.voiceController = self.voiceController
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView = NavigationMapView(frame: view.bounds)
        
        view.addSubview(mapView)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        let lpgr = UILongPressGestureRecognizer(target: self, action: "didLongPress:")
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.mapView.addGestureRecognizer(lpgr)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        voiceController = nil
    }
    
    func drawRoute(route: Route) {
        
        guard route.coordinateCount > 0 else { return }
        // Convert the route’s coordinates into a polyline
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        // If there's already a route line on the map, reset its shape to the new route
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
            
            // Add the source and style layer of the route line to the map
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
        }
    }
    

    
    func calculateRoute(from origin: CLLocationCoordinate2D, completion: @escaping (Route?, Error?) -> ()) {
        
        var str: String = "https://runningapp-api-heroku.herokuapp.com/data/?lat=\(Double(curLocation.coordinate.latitude))&lng=\(Double(curLocation.coordinate.longitude))&dist=\(self.distance)"
        Alamofire.request(str).responseJSON { response in
            
            if let data = response.data {
                
                let listOfCoordinates: [Coordinate]? = try? JSONDecoder().decode([Coordinate].self, from: data)
                if let list = listOfCoordinates {
                    for index in 0...(list.count-1) {
                        
                        let waypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: list[index].lat, longitude: list[index].lng), coordinateAccuracy: -1)
                        self.waypoints.append(waypoint)
                        
                    }
                    
                    
                    let options = NavigationRouteOptions(waypoints: self.waypoints, profileIdentifier: .automobileAvoidingTraffic)
                    
                    _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
                        self.directionsRoute = routes?.first
                        self.drawRoute(route: self.directionsRoute!)
                    }
                    
                }
                
                
            }
        
    }
        
        let options = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: .walking)
        
        // Generate the route object and draw it on the map
        _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
            self.directionsRoute = routes?.first
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
    



