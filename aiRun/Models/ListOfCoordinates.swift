//
//  ListOfCoordinates.swift
//  aiRun
//
//  Created by Michael Sun on 7/19/18.
//  Copyright © 2018 Michael Sun and Eric Frankel. All rights reserved.
//

import Foundation
import UIKit

struct ListOfCoordinates: Codable {
    
    let listOfCoordinates: [Coordinate]
    
    init(list: [Coordinate]) {
        
        self.listOfCoordinates = list
        
    }
    
}
