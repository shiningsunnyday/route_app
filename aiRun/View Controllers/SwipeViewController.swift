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
import FirebaseAuth

class SwipeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var email: UITextField!

    var stalker: UILabel?
    
    @IBOutlet weak var emailText: UITextField!
    
    var delegate: UserDelegate?
    
    var identifier: String?
    var boo2 = false
    var newUser = false
    var performedSegue = false { didSet {
        if let view = self.view.viewWithTag(10) {
            view.removeFromSuperview()
        
        }}}
    
    
    @IBOutlet weak var runName: UILabel!
    
    @IBAction func didPress(_ sender: Any) {
        
        
        boo2 = true
        if !boo {
            
            
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = .whiteLarge
            
            activityIndicator.color = UIColor.black
            
        
            self.view.addSubview(activityIndicator)
            
            self.view.addSubview(stalker!)
            activityIndicator.startAnimating()
            
            
        } else {
            
            if !self.performedSegue {
            self.performSegue(withIdentifier: "start", sender: nil)
                self.performedSegue = true
            }
            
        }
        
        
        
        if boo {
            
            if !self.performedSegue {
                self.performSegue(withIdentifier: "start", sender: nil)
                self.performedSegue = true
            }
        }
        
        
        
        
    }
    

    
    var locationManager = CLLocationManager()
    var boo = false { didSet {
        
        if boo2 {
        activityIndicator.stopAnimating()
            if !self.performedSegue {
                self.performSegue(withIdentifier: "start", sender: nil)
                self.performedSegue = true
                
            }
        }
        
        }}

    var activityIndicator = UIActivityIndicatorView()
    var curLocation = CLLocation()
    

    @IBOutlet weak var loginButton: UIButton!
    
    @objc func buttonEnabled() {
        
        self.loginButton.isEnabled = true
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.runName.attributedText = NSAttributedString(string: "aiRoute")
        self.loginButton.isEnabled = false
        self.button.layer.borderWidth = 0.5
        activityIndicator.center = CGPoint(x: self.view.center.x, y: self.view.center.x)
        stalker = UILabel(frame: CGRect(x: activityIndicator.frame.midX - 50, y: activityIndicator.frame.midY + 20, width: 100, height: 40))
        
        stalker?.attributedText = NSAttributedString(string: "Stalking your location")
        stalker?.textAlignment = .center
        stalker?.adjustsFontSizeToFitWidth = true
        stalker?.tag = 10
        stalker?.highlightedTextColor = UIColor.lightGray
        
        
        
        
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "sunset.jpg", ofType: nil)!)
        let imageData = try! Data(contentsOf: url)
        self.imageView.image = UIImage(data: imageData)
        
        self.emailText.borderStyle = .bezel
        self.emailText.layer.borderWidth = 0.5
        
        
        self.imageView.sizeToFit()
        
        
        self.emailText.addTarget(self, action: #selector(SwipeViewController.buttonEnabled), for: .editingChanged)
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SwipeViewController.didPress)))
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SwipeViewController.dismissKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        print("Keyboard will show: \(notification.name.rawValue)")
        
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == Notification.Name.UIKeyboardWillShow ||
            notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            view.frame.origin.y = -keyboardRect.height + 192
        } else {
            view.frame.origin.y = 0
        }
    }
    
    var offset: CGFloat = 128
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        view.layoutIfNeeded()
        let bottomOfScreen: CGFloat = scrollView.contentSize.height - view.frame.height + offset
        offset = 64
        scrollView.setContentOffset(CGPoint(x: 0, y: bottomOfScreen), animated: false)
        
    }
    
    @IBOutlet weak var button: UIButton!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case "start":
            
            let destination = segue.destination as! MapViewController
            
            destination.curLocation = self.curLocation
            destination.newUser = newUser
            if let email = email.text {
                
                
                Auth.auth().createUser(withEmail: email, password: "......") { user, error in
                    
                    
                    
                    if error == nil {
                        destination.newUser = true
                        
                        
                        Auth.auth().signIn(withEmail: email, password: "......")
                    } else {
                        
                        
                        destination.newUser = false
                        Auth.auth().signIn(withEmail: email, password: "......")
                        
                    }
                    
                    
                }
                
                
                
            }
            
            
            
            
        
            
            
            
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

extension SwipeViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SwipeViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
