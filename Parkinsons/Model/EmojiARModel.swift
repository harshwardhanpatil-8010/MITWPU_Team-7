//
//  ARModel.swift
//  Emoji_Face_Match
//
//  Created by Cole Dennis on 10/30/22.
//
/*
import Foundation
import RealityKit
import ARKit
import AVFoundation
import CoreHaptics

struct ARModel {
    // MARK: AR Setup
    private(set) var arView : ARView
    // Removed FaceRing dependency; if you add a Reality Composer asset later, reintroduce it.
    // var faceRing: FaceRing.Scene? // RCProject AR Ring On Success
    
    var faceTrackingEnabled: Bool = true
    
    var mouthStatus: mouthScale = .neutral
    var eyebrowStatus: eyebrowScale = .neutral
    var eyeStatus: eyeScale = .neutral
    
    // MARK: Game Setup
    var gameStageVar: GameStage = .menu
    var isGameActive: Bool = false
    var engine: CHHapticEngine?
    
    // MARK: Game Data
    var facesArray: Array<faces> = []
    var collectedFaces: Array<faces> = []
    var currentScore: Int = 0
    var gametime: Int = 0
    var switchPlayer: Bool = false
    var countdownTime: Int = 3
    
    // MARK: Audio Variables
    var successAudio: AVAudioPlayer?
    var endingAudio: AVAudioPlayer?
    var countdownAudio: AVAudioPlayer?
    
    // MARK: INIT
    init() {
        arView = ARView(frame: .zero)
        setupARView(gameStage: .menu)

        // If you add a Reality Composer asset named FaceRing later, you can re-enable this:
        // let faceRingAnchor = try! FaceRing.loadScene()
        // faceRing = faceRingAnchor
        // arView.scene.anchors.append(faceRingAnchor)

        gameSetup()
        audioSetup()
    }
    
    // MARK: AR Logic
    mutating func setupARView(gameStage: GameStage){
        if !ARWorldTrackingConfiguration.supportsUserFaceTracking {
            faceTrackingEnabled = false
        }
        let config = ARFaceTrackingConfiguration()
        config.frameSemantics.insert(.personSegmentation)
        arView.session.run(config)
    }
    
    
    // MARK: Face Logic
    
    mutating func update(faceAnchor: ARFaceAnchor){
        
        // LIPS
        let smileRight = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .mouthSmileRight})?.value ?? 0)
        let smileLeft = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .mouthSmileLeft})?.value ?? 0)
        let frownRight = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .mouthFrownRight})?.value ?? 0)
        let frownLeft = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .mouthFrownLeft})?.value ?? 0)
        let mouthFunnel = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .mouthFunnel})?.value ?? 0)
        let mouthPucker = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .mouthPucker})?.value ?? 0)
        let tongueOut = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .tongueOut})?.value ?? 0)
        /*let*/ mouthStatus = mouthCheck(tongueOut: tongueOut, frownLeft: frownLeft, frownRight: frownRight, smileLeft: smileLeft, smileRight: smileRight, mouthPucker: mouthPucker, mouthFunnel: mouthFunnel)
        
        
        // EYES?
        let eyeWideLeft = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .eyeWideLeft})?.value ?? 0)
        let eyeWideRight = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .eyeWideRight})?.value ?? 0)
        let eyeSquintLeft = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .eyeSquintLeft})?.value ?? 0)
        let eyeSquintRight = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .eyeSquintRight})?.value ?? 0)
        let eyeBlinkLeft = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .eyeBlinkLeft})?.value ?? 0)
        let eyeBlinkRight = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .eyeBlinkRight})?.value ?? 0)
        let eyeLookUpLeft = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .eyeLookUpLeft})?.value ?? 0)
        let eyeLookUpRight = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .eyeLookUpRight})?.value ?? 0)
        /*let*/ eyeStatus = eyeCheck(eyeBlinkLeft: eyeBlinkLeft, eyeBlinkRight: eyeBlinkRight, eyeWideLeft: eyeWideLeft, eyeWideRight: eyeWideRight, eyeLookUpLeft: eyeLookUpLeft, eyeLookUpRight: eyeLookUpRight, eyeSquintLeft: eyeSquintLeft, eyeSquintRight: eyeSquintRight)
        
        
        // EYEBROWS
        let eyebrowInnerUp = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .browInnerUp})?.value ?? 0)
        let eyebrowDownLeft = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .browDownLeft})?.value ?? 0)
        let eyebrowDownRight = Float(truncating: faceAnchor.blendShapes.first(where: {$0.key == .browDownRight})?.value ?? 0)
        /*let*/  eyebrowStatus = eyebrowCheck(eyebrowInnerUp: eyebrowInnerUp, eyebrowDownLeft: eyebrowDownLeft, eyebrowDownRight: eyebrowDownRight)
        
        if facesArray.count > 0 && switchPlayer == false && countdownTime == 0 {
            faceCheck(face: facesArray.first!, eyes: eyeStatus, eyebrows: eyebrowStatus, mouth: mouthStatus)
        }
    }
    
    
    mutating func faceCheck(face: faces, eyes: eyeScale, eyebrows: eyebrowScale, mouth: mouthScale ) {
        if (face.eyeScale.contains(where: {$0 == eyes})) && (face.eyebrowScale.contains(where: {$0 == eyebrows})) && (face.mouthScale.contains(where: {$0 == mouth})) {
            if gameStageVar == .hotPotato {
                switchPlayer = true
            }
            currentScore += 1
            
            simpleSuccess()
            collectedFaces.append(facesArray[0])
            facesArray.remove(at: 0)
            
            // If a Reality Composer ring animation exists, trigger it here.
            // faceRing?.notifications.ringAnimation.post()
            
            playSuccessAudio()
        }
    }
    
    mutating func eyebrowCheck(eyebrowInnerUp: Float, eyebrowDownLeft: Float, eyebrowDownRight: Float) -> eyebrowScale {
        
        var result = eyebrowScale.neutral
        
        if eyebrowInnerUp > 0.6 && eyebrowDownLeft == 0 && eyebrowDownRight == 0 {
            result = .surprised
        } else if eyebrowInnerUp > 0.1 && ( (eyebrowDownLeft < 0.3 && eyebrowDownLeft > 0 ) || ( eyebrowDownRight < 0.3 && eyebrowDownRight > 0 )) {
            result = .splitSkeptical
        } else if eyebrowDownRight > 0.7 && eyebrowDownLeft > 0.7 {
            result = .furrowed
        }
        
        return result
    }
    
    mutating func eyeCheck(eyeBlinkLeft: Float, eyeBlinkRight: Float, eyeWideLeft: Float, eyeWideRight: Float, eyeLookUpLeft: Float, eyeLookUpRight: Float, eyeSquintLeft: Float, eyeSquintRight: Float) -> eyeScale {
        
        var result = eyeScale.neutral
        
        if eyeLookUpLeft > 0.7 && eyeLookUpRight > 0.7 {
            result = .rollingEyesUp
        } else if eyeBlinkLeft > 0.8 && eyeBlinkRight > 0.8 {
            result = .closed
        } else if eyeWideLeft > 0.5 && eyeWideRight > 0.5 {
            result = .wideOpen
        }  else if (eyeBlinkLeft > 0.8 && eyeBlinkRight < 0.2) || (eyeBlinkRight > 0.8 && eyeBlinkLeft < 0.2) {
            result = .wink
        } else if eyeSquintLeft > 0.3 && eyeSquintRight > 0.3 {
            result = .squinting
        }
        
        return result
    }
    
    mutating func mouthCheck(tongueOut: Float, frownLeft: Float, frownRight: Float, smileLeft: Float, smileRight: Float, mouthPucker: Float, mouthFunnel: Float) -> mouthScale {
        
        var result = mouthScale.neutral
        
        if tongueOut > 0.2 {
            result = .tongueOut
        } else if mouthPucker > 0.7 {
            result = .kissFace
        } else if frownLeft > 0.35 && frownRight > 0.35 {
            result = .frown
        } else if smileLeft > 0.4 && smileRight > 0.4 {
            if mouthFunnel > 0.04 {
                result = .openMouthSmile
            } else {
                result = .smile
            }
        } else if mouthFunnel > 0.1 {
            result = .openMouthNeutral
        }
        
        return result
    }
    
    
    // MARK: Game Setup Logic
    mutating func updateGameStage(gameStage: GameStage) {
        gameStageVar = gameStage
    }
    
    mutating func toggleGameActiveTrue() {
        isGameActive = true
    }
    
    mutating func toggleGameActiveFalse() {
        isGameActive = false
    }
    
    mutating func updateGameTime() {
        switch gameStageVar {
        case .singlePlayer: gametime -= 1
        case .hotPotato: gametime += 1
        default: break
        }
    }
    
    mutating func countdownTimeUpdate() {
        countdownTime -= 1
    }
    
    mutating func gameSetup() {
        switchPlayer = false
        countdownTime = 3
        currentScore = 0
        if gameStageVar == .singlePlayer {
            gametime = 15
        } else if gameStageVar == .hotPotato {
            gametime = 0
        }
        
        facesArray = []
        for face in faces.allCases {
            facesArray.append(face)
        }
        facesArray.shuffle()
        collectedFaces = []
    }
    
    mutating func switchPlayers() {
        switchPlayer.toggle()
    }
    
    
    // MARK: Audio Setup
    mutating func audioSetup() {
        let successPath = Bundle.main.path(forResource: "Success V5.wav", ofType:nil)!
        let successUrl = URL(fileURLWithPath: successPath)
        
        let endingAudioPath = Bundle.main.path(forResource: "Ending Audio.wav", ofType:nil)!
        let endingAudioUrl = URL(fileURLWithPath: endingAudioPath)
        
        let countdownAudioPath = Bundle.main.path(forResource: "Countdown.wav", ofType:nil)!
        let countdownAudioUrl = URL(fileURLWithPath: countdownAudioPath)
        
        do {
            successAudio = try AVAudioPlayer(contentsOf: successUrl)
            endingAudio = try AVAudioPlayer(contentsOf: endingAudioUrl)
            countdownAudio = try AVAudioPlayer(contentsOf: countdownAudioUrl)
        } catch {
            print("could not access success audio")
        }
    }
    
    func playSuccessAudio() {
        successAudio?.play()
    }
    
    func playEndingAudio() {
        endingAudio?.play()
    }
    
    func playCountdownAudio() {
        countdownAudio?.play()
    }
    
    // MARK: Haptic Setup
    mutating func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func buttonTapHaptic() {
        let impactMed = UIImpactFeedbackGenerator(style: .light)
        impactMed.impactOccurred()
    }
    
    func endingHaptic() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        for i in stride(from: 0, to: 0.4, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(0.5))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.2))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.4)
        events.append(event)
        
        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

*/
