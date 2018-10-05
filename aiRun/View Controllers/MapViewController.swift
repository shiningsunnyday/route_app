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
import Firebase
import AVFoundation


class MapViewController: UIViewController, MGLMapViewDelegate, UIGestureRecognizerDelegate, UIToolbarDelegate {
    
    
    var mapView: NavigationMapView!
    var name: String = "Michael"
    var navBar: UINavigationBar?
    var width: Double?
    var directionsRoute: Route?
    
    var distance: Double = 0.0
    var currentKey = ""
    var curLocation = CLLocation()
    var waypoints: [Waypoint] = []
    var label: UILabel!
    var state: Int = 0
    var routeFailed = 0
    var newUser = false
    
    var voiceController: CustomVoiceController?
    var currentAnnotation = MGLPointAnnotation()
    
    
    
    
    func userConfirmed(_ confirmed: Bool) {
        
        self.newUser = confirmed
        self.voiceController = CustomVoiceController(self.newUser)
        
        
    }
    
    
    
    @objc func goBack(_ sender: UISwipeGestureRecognizer) {
        
        self.performSegue(withIdentifier: "goBack", sender: nil)
        
    }
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        
        guard sender.state == .began else { return }
        
        if state == 0 {
            
            
            currentAnnotation.coordinate = curLocation.coordinate
            currentAnnotation.title = "Help me calculate a route!"
            
            mapView.addAnnotation(currentAnnotation)
            mapView.selectAnnotation(currentAnnotation, animated: true)
            
        }
        
    }
    
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    
    
    @objc func buttonTouched(_ sender: UITapGestureRecognizer)
    {
        
        let route = directionsRoute
        let ref = Database.database().reference(withPath: "route-committed")
        let nameref = ref.child(self.name).child(currentKey)
        
        var coordinateList = [[]]
        
        if let coordinates = route?.coordinates {
            for i in 0...coordinates.count-1 {
                
                coordinateList.append([Float(coordinates[i].latitude), Float(coordinates[i].longitude)])
                
            }
            let dic = ["route": coordinateList] as NSDictionary
            nameref.updateChildValues(dic as! [AnyHashable : Any])
            
        }
        
        
        let navigationViewController = NavigationViewController(for: directionsRoute!)
        navigationViewController.showsReportFeedback = false
        navigationViewController.voiceController = self.voiceController
        
        self.present(navigationViewController, animated: true, completion: nil)
        
    }
    
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        
        mapView.deselectAnnotation(annotation, animated: true)
        
        switch state {
            
        case 0:
            
            state += 1
            currentAnnotation.title = "Let me crunch the math..."
            mapView.selectAnnotation(currentAnnotation, animated: true)
            
            
            
        case 1:
            
            if let coordinates = directionsRoute?.coordinates {
                
                let ref = Database.database().reference(withPath: "route")
                let nameref = ref.child(self.name).child(currentKey)
                
                var coordinateList = [[]]
                
                for i in 0...coordinates.count-1 {
                    
                    coordinateList.append([Float(coordinates[i].latitude), Float(coordinates[i].longitude)])
                    
                }
                
                
                let dic = ["route": coordinateList, "applied distance": self.distance, "distance": directionsRoute!.distance] as NSDictionary
                nameref.updateChildValues(dic as! [AnyHashable : Any])
                routeFailed += 1
                
                
            }
            
            
            
            if routeFailed == 1 {
            currentAnnotation.title = "Let me crunch the math again..."
                mapView.selectAnnotation(currentAnnotation, animated: true)
            } else if routeFailed >= 5 {
                
                currentAnnotation.title = "Still? You are one FASTidious runner..."
                mapView.selectAnnotation(currentAnnotation, animated: true)
            }
            
            else if routeFailed >= 2 {
                currentAnnotation.title = "Let me crunch the math AGAIN..."
                mapView.selectAnnotation(currentAnnotation, animated: true)
                
            }
            
            
            

            
        default:
            
            return
            
        }
        
        calculateRoute(from: annotation.coordinate) { (route, error) in
            
            if error != nil {
                
            }
        }
        
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.width = Double(self.view.frame.width)
        navBar = UINavigationBar(frame: CGRect(x: 0, y: 44, width: self.width!, height: 44))
        let backItem = UINavigationItem(title: "Swipe left to go back")
        navBar!.items = [backItem]
        
        self.view.addSubview(navBar!)
        
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "goBack:")
        swipeRecognizer.direction = .left
        navBar!.addGestureRecognizer(swipeRecognizer)
        
        navBar!.setItems([backItem], animated: false)
        
        mapView = NavigationMapView(frame: CGRect(x: 0, y: 88, width: self.view.frame.width, height: self.view.frame.height - 132))
        self.label = UILabel(frame: CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44))
        
        if newUser {
            
            label.attributedText = NSAttributedString(string: "  Welcoming message being played. Please turn up the volume.  ")
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            label.backgroundColor = UIColor.yellow
            
            let newUserMessage = UITapGestureRecognizer(target: self, action: "welcomeTouched:")
            newUserMessage.delegate = self
            self.label.addGestureRecognizer(newUserMessage)
            self.voiceController = CustomVoiceController(true)
            let timer = Timer.scheduledTimer(withTimeInterval: 85.0, repeats: false) { timer in
                
                self.label.attributedText = NSAttributedString(string: "Long tap your location beacon to begin.")
                self.label.textAlignment = .center
                self.label.backgroundColor = UIColor.lightGray
                
                
                
            }
            self.view.addSubview(label)
            
        } else {
        
        label.attributedText = NSAttributedString(string: "Long tap your location beacon to begin.")
        label.textAlignment = .center
        label.backgroundColor = UIColor.lightGray
        self.view.addSubview(label)
            
        }
        
        self.view.addSubview(mapView)
        self.view.backgroundColor = UIColor.white
        
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
        
    }
    
    func drawRoute(route: Route) {
        
        guard route.coordinateCount > 0 else { return }
        if let navBar = self.navBar {
            let distance = route.distance
            let time = route.expectedTravelTime.description
            print(distance/Double(time)!)
            navBar.items![0].title = "Distance: \(Int(distance/1000)).\(Int(Int((distance-Double(1000*Int(distance/Double(1000))))/100))) kilometers, Est. Time: \(Int(distance/1000/8*60)) mins"
        }
        // Convert the route’s coordinates into a polyline
        var routeCoordinates = route.coordinates!
        routeCoordinates.append(routeCoordinates[0])
        let polyline = MGLPolylineFeature(coordinates: routeCoordinates, count: route.coordinateCount + 1)
        
        // If there's already a route line on the map, reset its shape to the new route
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineWidth = NSExpression(forConstantValue: 5)
            
            // Add the source and style layer of the route line to the map
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
            
            
            
            self.label.backgroundColor = UIColor.green
            self.label.text = "Click here to begin!"
            let begin = UITapGestureRecognizer(target: self, action: "buttonTouched:")
            begin.delegate = self
            self.view.addGestureRecognizer(begin)
            
            
            
        }
        
        mapView.deselectAnnotation(mapView.annotations?[0], animated: true)
        
        
        if routeFailed == 0 {
            
            currentAnnotation.title = "Is this a bad route? Tap to regenerate."
            
        } else {
            
            currentAnnotation.title = "Is this another bad route? Tap to regenerate."
            
        }
        
        mapView.selectAnnotation(currentAnnotation, animated: true)
        
    }
    
    func calculateRoute(from origin: CLLocationCoordinate2D, completion: @escaping (Route?, Error?) -> ()) {
        
        let str: String = "https://runningapp-api-heroku.herokuapp.com/data/?lat=\(Double(curLocation.coordinate.latitude))&lng=\(Double(curLocation.coordinate.longitude))&dist=\(self.distance/(2))"
        
        Alamofire.request(str).responseJSON { response in
            
            if let data = response.data {
                
                let listOfCoordinates: [Coordinate]? = try? JSONDecoder().decode([Coordinate].self, from: data)
                
                if let list = listOfCoordinates {
                    
                    self.waypoints = []
                    for index in -1...(list.count-1) {
                        
                        if index < 0 {
                            
                            self.waypoints.append(Waypoint(coordinate: self.curLocation.coordinate))
                        } else {
                        let waypoint = Waypoint(coordinate: CLLocationCoordinate2D(latitude: list[index].lat, longitude: list[index].lng), coordinateAccuracy: -1)
                        self.waypoints.append(waypoint)
                        }
                        
                    }
    
                    
                    let options = NavigationRouteOptions(waypoints: self.waypoints, profileIdentifier: .walking)
                    
                    _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
                        
                        
                        self.directionsRoute = routes?.first
                        let route = routes?.first
                        let ref = Database.database().reference(withPath: "route")
                        let nameref = ref.child(self.name).childByAutoId()
                        self.currentKey = nameref.key!
                        var coordinateList = [[]]
                        
                        if let coordinates = route?.coordinates {
                            
                        for i in 0...coordinates.count-1 {
                            
                            coordinateList.append([Float(coordinates[i].latitude), Float(coordinates[i].longitude)])
                            
                        }
                            
                            let dic = ["route": coordinateList, "applied distance": self.distance, "distance": route?.distance] as NSDictionary
                            
                            nameref.updateChildValues(dic as! [AnyHashable : Any])
                        }
                        
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
    



