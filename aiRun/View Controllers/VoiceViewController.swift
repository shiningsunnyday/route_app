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
    
    var newUser: Bool = false
    var welcome: AVAudioPlayer?
    var delegate: PlayerDelegate?
    
    init(_ newUser: Bool) {
        
        super.init()
        self.newUser = newUser
        do {
        self.welcome = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "welcome.MP4", ofType: nil)!))
        } catch {
            print("Oh")
        }
        
        if newUser {
        intro()
        }
    }
    
    
    
    
    func intro() {
    
        guard let path = Bundle.main.path(forResource: "welcome.MP4", ofType: nil) else { return }
        
        let url = URL(fileURLWithPath: path)
        welcome!.prepareToPlay()
        welcome!.play()
        
    }
    
    
    
    
    
    override func didPassSpokenInstructionPoint(notification: NSNotification) {
        
        let routeProgress = notification.userInfo![RouteControllerNotificationUserInfoKey.routeProgressKey] as! RouteProgress
        audio(for: routeProgress)                                                

    }
    
    func audio(for progress: RouteProgress) {
        
        let stepProgress = progress.currentLegProgress.currentStepProgress
        let nextStep = progress.currentLegProgress.upComingStep
        if stepProgress.userDistanceToManeuverLocation < 50 {
            
            guard let nextStep = nextStep else { return }
            
            let instruction = String(describing: nextStep.maneuverType) + String(describing: nextStep.maneuverDirection)
            print(instruction)
            
            var direction: String = ""
            switch nextStep.maneuverDirection {
                case .left:
                    direction = "turnleft.MP4"
                case .right:
                    direction = "turnright.MP4"
                case .slightLeft:
                
                    direction = "slightleft.MP4"
                case .slightRight:
                    direction = "slightright.MP4"
                case .straightAhead:
                    direction = "gostraight.MP4"
                case .uTurn:
                    direction = "turnaround.MP4"
                default:
                    direction = "gostraight.MP4"
            }
            
            let path = Bundle.main.path(forResource: direction, ofType: nil)!
            
            let url = URL(fileURLWithPath: path)
            
            do {
                //create your audioPlayer in your parent class as a property
                let audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print("couldn't load the file")
            }
        }
    }
    
}
