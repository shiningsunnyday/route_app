//
//  LocationProtocol.swift
//  aiRun
//
//  Created by Michael Sun on 8/5/18.
//  Copyright © 2018 Michael Sun and Eric Frankel. All rights reserved.
//

import UIKit
import MapKit

protocol LocationDelegate {
    
    func locationReady(location: CLLocation)
    
}
