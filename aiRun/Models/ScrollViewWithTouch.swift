//
//  ScrollViewWithTouch.swift
//  aiRun
//
//  Created by Michael Sun on 9/18/18.
//  Copyright © 2018 Michael Sun and Eric Frankel. All rights reserved.
//

import Foundation
import UIKit

class scrollViewWithTouch: UIView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let position = touch.location(in: self)
            print(position)
            
        }
    }
    
}
