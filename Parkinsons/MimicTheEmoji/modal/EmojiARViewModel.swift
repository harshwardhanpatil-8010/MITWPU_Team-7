//
//  ARViewModel.swift
//  Emoji_Face_Match
//
//  Created by Cole Dennis on 10/30/22.
//

import Foundation
import RealityKit
import ARKit
import CoreHaptics
import SwiftUI
/*
class ARViewModel: UIViewController, ObservableObject, ARSessionDelegate {
        
    // MARK: AR Setup
    @Published var model : ARModel = ARModel()
    
    var arView : ARView {
        model.arView
    }
    
    func startSessionDelegate() {
        model.arView.session.delegate = self
        requestPermission()
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        if model.isGameActive {
            
            if let faceAnchor = anchors.first  as? ARFaceAnchor {
                model.update(faceAnchor: faceAnchor)
            }
        }
    }
    
    // MARK: Game Setup
    var gameStage: GameStage {
        model.gameStageVar
    }
    
    func changeGameStage(newGameStage: GameStage) {
        model.setupARView(gameStage: newGameStage)
        model.updateGameStage(gameStage: newGameStage)
        if gameStage == .menu || gameStage == .ending {
            model.isGameActive = false
        }
    }
    
    var isGameActive: Bool {
        model.isGameActive
    }
    
    func toggleGameActiveTrue() {
        model.toggleGameActiveTrue()
    }
    
    func toggleGameActiveFalse() {
        model.toggleGameActiveFalse()
    }
    
    func playEndingAudio() {
        model.playEndingAudio()
    }
    
    func playCountdownAudio() {
        model.playCountdownAudio()
    }
    
    func playSuccessAudio() {
        model.playSuccessAudio()
    }
    
    func gameSetup() {
        model.gameSetup()
    }
    
    // MARK: Haptics 
    func simpleSuccess() {
        model.simpleSuccess()
    }
    
    func buttonHaptic() {
        model.buttonTapHaptic()
    }
    
    func endingHaptic() {
        model.endingHaptic()
    }
    
    func prepareHaptics() {
        model.prepareHaptics()
    }
    
    // MARK: Game Data
    var score: Int {
        model.currentScore
    }
    
    var facesArray: Array<faces> {
        model.facesArray
    }
    
    func shuffle() {
        model.facesArray.shuffle()
    }
    
    var gameTime: Int {
        model.gametime
    }
   

    func updateGameTime() {
        model.updateGameTime()
    }
    
    var countdownTime: Int {
        model.countdownTime
    }
    
    func countdownTimeUpdate() {
        model.countdownTimeUpdate()
    }
    
    var switchPlayer: Bool {
        model.switchPlayer
    }
    
    func switchPlayerToggle() {
        model.switchPlayers()
    }
    
    // MARK: Testing Data
//        var mouthStatus: mouthScale {
//            model.mouthStatus
//        }
//    
//        var eyebrowStatus: eyebrowScale {
//            model.eyebrowStatus
//        }
//    
//        var eyeStatus: eyeScale {
//            model.eyeStatus
//        }
 
    @Published var permissionGranted = true
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            DispatchQueue.main.async {
                withAnimation() {
                    self.permissionGranted = accessGranted
                }
            }
        })
    }
    
    var faceTrackingEnabled: Bool {
        model.faceTrackingEnabled
    }
    
}
*/
