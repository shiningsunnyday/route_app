//
//  voiceViewController.swift
//  aiRun
//
//  Created by Michael Sun on 9/9/18.
//  Copyright © 2018 Michael Sun and Eric Frankel. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import AVFoundation

class CustomVoiceController: MapboxVoiceController {
    
    let turnLeft = NSDataAsset(name: "turnleft")!.data
    let turnRight = NSDataAsset(name: "turnright")!.data
    let straight = NSDataAsset(name: "continuestraight")!.data
    
    override func didPassSpokenInstructionPoint(notification: NSNotification) {
        let routeProgress = notification.userInfo![RouteControllerNotificationUserInfoKey.routeProgressKey] as! RouteProgress
        let soundForInstruction = audio(for: routeProgress.currentLegProgress.currentStep)
        play(soundForInstruction)
    }
    
    func audio(for step: RouteStep) -> Data {
        switch step.maneuverDirection {
        case .left:
            return turnLeft
        case .right:
            return turnRight
        default:
            return straight
        }
    }
    
}
