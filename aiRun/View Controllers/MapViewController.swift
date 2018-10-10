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
    
    var labelDown: UILabel?
    var textField: UITextField?
    var mapView: NavigationMapView!
    var name: String = "Michael"
    var navBar: UINavigationBar?
    var width: Double?
    var directionsRoute: Route?
    
    var distance: Double?
    var currentKey = ""
    var curLocation = CLLocation()
    var waypoints: [Waypoint] = []
    var label: UILabel!
    var state: Int = 0
    var routeFailed = 0
    var newUser: Bool! { didSet {
        
        
        voiceController = CustomVoiceController(newUser)
        
        
        playOpeningMessage()
        
        }}
    
    var voiceController: CustomVoiceController?
    var currentAnnotation = MGLPointAnnotation()
    
    func playOpeningMessage() {
        if newUser {
        
        guard let labelDown = labelDown else { return }
        labelDown.attributedText = NSAttributedString(string: "  Welcoming message being played. Please turn up the volume.  ")
        self.textField!.isEnabled = false
        labelDown.adjustsFontSizeToFitWidth = true
        labelDown.textAlignment = .center
        labelDown.backgroundColor = UIColor.yellow
        
        let newUserMessage = UITapGestureRecognizer(target: self, action: "welcomeTouched:")
        newUserMessage.delegate = self
        labelDown.addGestureRecognizer(newUserMessage)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 85.0, repeats: false) { timer in
            
            labelDown.attributedText = NSAttributedString(string: "Swipe left here anytime to return to the home page.")
            labelDown.textAlignment = .center
            labelDown.backgroundColor = UIColor.lightText
            self.textField!.backgroundColor = UIColor.yellow
            self.textField?.isEnabled = true
            
        }
        self.view.addSubview(labelDown)
        }
    }
    
    
    
    @objc func goBack(_ sender: UISwipeGestureRecognizer) {
        
        switch sender.direction {
            case .left:
                self.performSegue(withIdentifier: "goBack", sender: nil)
        case .right:
            print("hi")
            
        default:
            print("hi")
            
        }
    }
    
    /*@objc func distanceChanged(_ textField: UITextField) {
        
        didLongPress(UILongPressGestureRecognizer(self))
    }*/
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        
        if let field = self.textField {
            
            self.distance = Double(field.text!)
            self.textField!.backgroundColor = UIColor.green
        }
        
        if state == 0 {
            
            currentAnnotation.coordinate = curLocation.coordinate
            currentAnnotation.title = "Fetching a random route..."
            
            mapView.addAnnotation(currentAnnotation)
            mapView.selectAnnotation(currentAnnotation, animated: true)
            autoTap()
            
 
            
        }
        
    }
    
    func autoTap() {
        
        calculateRoute(from: self.curLocation.coordinate) { (route, error) in
            
            if error != nil {
                
            }
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
        navigationViewController.routeController.reroutesProactively = true

        print(navigationViewController.routeController.reroutingTolerance)
        navigationViewController.voiceController = self.voiceController
        
        self.present(navigationViewController, animated: true, completion: nil)
        
    }
    
    
    
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        
        mapView.deselectAnnotation(annotation, animated: true)
        
        switch state {
            
        case 0:
            
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
                
                currentAnnotation.title = "You are one FASTidious runner..."
                mapView.selectAnnotation(currentAnnotation, animated: true)
            }
            
            else if routeFailed >= 2 {
                currentAnnotation.title = "Let me crunch the math AGAIN..."
                mapView.selectAnnotation(currentAnnotation, animated: true)
                
            }
            
            
            autoTap()

            
        default:
            
            return
            
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.width = Double(self.view.frame.width)
        navBar = UINavigationBar(frame: CGRect(x: 0, y: 44, width: self.width!, height: 44))
        navBar?.backgroundColor = UIColor.lightGray
        let newItem = UINavigationItem(title: "")
        label = UILabel(frame: CGRect(x: 20, y: 44, width: navBar!.frame.width/2 - 20, height: navBar!.frame.height))
        label.attributedText = NSAttributedString(string: "Enter running distance (km): ")
        
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.tag = 5
        navBar!.setItems([newItem], animated: true)
        navBar!.backItem?.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: nil)
        
        navBar!.tag = 1
        
        
        textField = UITextField(frame: CGRect(x: navBar!.frame.width/2, y: navBar!.frame.minY + 10, width: navBar!.frame.width/2 - 20, height: navBar!.frame.height - 20))
        textField!.borderStyle = .roundedRect
        textField!.keyboardType = .decimalPad
        textField!.tag = 6
        textField!.textAlignment = .center
        textField!.font = UIFont(name: "Arial", size: 12)
        textField!.addTarget(self, action: #selector(self.didLongPress(_:)), for: .editingChanged)
        textField!.addTarget(self, action: #selector(self.dismissKeyboard), for: .editingChanged)
        
        
        
        
        
        
        
        
        
        
        
        mapView = NavigationMapView(frame: CGRect(x: 0, y: 88, width: self.view.frame.width, height: self.view.frame.height - 132))
       
        labelDown = UILabel(frame: CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44))
        if let labelDown = self.labelDown {
            
        if self.newUser {
            
            
            
            
        } else {
        
        
            
        labelDown.attributedText = NSAttributedString(string: "Swipe left here anytime to return to the home page.")
        labelDown.textAlignment = .center
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.goBack(_:)))
        swipeRecognizer.direction = .left
        swipeRecognizer.delegate = self
        self.view.addGestureRecognizer(swipeRecognizer)
        labelDown.backgroundColor = UIColor.lightText
        self.view.addSubview(labelDown)
            
        }
        mapView.tag = 0
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
        
        self.view.addSubview(navBar!)
        self.view.addSubview(label)
        self.view.addSubview(textField!)
        
        
    }
    
    
    func drawRoute(route: Route) {
        
        guard route.coordinateCount > 0 else { return }
        if let navBar = self.navBar {
            let distance = route.distance
            let time = route.expectedTravelTime.description
            print(distance/Double(time)!)
            if let view = self.view.viewWithTag(5), let view2 = self.view.viewWithTag(6) {
                view.removeFromSuperview()
                view2.removeFromSuperview()
            }
            navBar.items![0].title = "Distance: \(Int(distance/1000)).\(Int(Int((distance-Double(1000*Int(distance/Double(1000))))/100))) km, Est. Time: \(Int(distance/1000/8*60)) mins"
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
            
            
            
            
            self.labelDown!.backgroundColor = UIColor.green
            self.labelDown!.text = "Click here to begin!"
            let begin = UITapGestureRecognizer(target: self, action: "buttonTouched:")
            begin.delegate = self
            self.view.addGestureRecognizer(begin)
            
            
            
        }
        
        if let view = self.view.viewWithTag(5), let view2 = self.view.viewWithTag(6) {
            
            view.removeFromSuperview()
            view2.removeFromSuperview()
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
        
        let str: String = "https://runningapp-api-heroku.herokuapp.com/data/?lat=\(Double(curLocation.coordinate.latitude))&lng=\(Double(curLocation.coordinate.longitude))&dist=\(self.distance!/(2))"
        
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        print("Keyboard will show: \(notification.name.rawValue)")
        
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == Notification.Name.UIKeyboardWillShow ||
            notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            view.frame.origin.y = -keyboardRect.height + 0
        } else {
            view.frame.origin.y = 0
        }
    }
}

extension MapViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


    



