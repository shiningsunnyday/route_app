//
//  Coordinate.swift
//  aiRun
//
//  Created by Michael Sun on 7/19/18.
//  Copyright © 2018 Michael Sun and Eric Frankel. All rights reserved.
//

import Foundation

struct Coordinate: Codable {
    
    let lat: Double
    let lng: Double
    
    init(lat: Double, long: Double) {
        
        self.lat = lat
        self.lng = long
        
    }
    
}
