import Foundation
import ARKit

struct EmojiChallenge {
    let emoji: String
    let name: String
    let check: (ARFaceAnchor) -> Bool
}

struct EmojiData {
    static let challenges: [EmojiChallenge] = [
        // 1. Original: Smiling Face
        EmojiChallenge(emoji: "😊", name: "Smiling Face", check: { anchor in
            let smileL = anchor.blendShapes[.mouthSmileLeft]?.floatValue ?? 0
            let smileR = anchor.blendShapes[.mouthSmileRight]?.floatValue ?? 0
            return smileL > 0.5 && smileR > 0.5
        }),
        // 2. Original: Surprised Face
        EmojiChallenge(emoji: "😲", name: "Surprised Face", check: { anchor in
            let jawOpen = anchor.blendShapes[.jawOpen]?.floatValue ?? 0
            return jawOpen > 0.4
        }),
        // 3. Kissing Face (Pucker) - Great for lip strength
        EmojiChallenge(emoji: "😗", name: "Pucker Lips", check: { anchor in
            let pucker = anchor.blendShapes[.mouthPucker]?.floatValue ?? 0
            return pucker > 0.7
        }),
        // 4. Tongue Out - Good for speech/swallowing muscles
        EmojiChallenge(emoji: "😛", name: "Stick Out Tongue", check: { anchor in
            let tongue = anchor.blendShapes[.tongueOut]?.floatValue ?? 0
            return tongue > 0.5
        }),
        // 5. Angry Face - Exercises the brow area
        EmojiChallenge(emoji: "😠", name: "Frown/Scowl", check: { anchor in
            let browDownL = anchor.blendShapes[.browDownLeft]?.floatValue ?? 0
            let browDownR = anchor.blendShapes[.browDownRight]?.floatValue ?? 0
            return browDownL > 0.5 && browDownR > 0.5
        }),
        // 6. Raised Eyebrows - Increases upper face range
        EmojiChallenge(emoji: "🤨", name: "Raise Eyebrows", check: { anchor in
            let browUpL = anchor.blendShapes[.browOuterUpLeft]?.floatValue ?? 0
            let browUpR = anchor.blendShapes[.browOuterUpRight]?.floatValue ?? 0
            return browUpL > 0.6 && browUpR > 0.6
        }),
        // 7. Winking Left - Isolates facial control
        EmojiChallenge(emoji: "😉", name: "Wink Left Eye", check: { anchor in
            let eyeCloseL = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            let eyeCloseR = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            return eyeCloseL > 0.8 && eyeCloseR < 0.2
        }),
        // 8. Puffed Cheeks - Works on cheek pressure
        EmojiChallenge(emoji: "🐡", name: "Puff Cheeks", check: { anchor in
            let puffL = anchor.blendShapes[.cheekPuff]?.floatValue ?? 0
            return puffL > 0.6
        }),
        // 9. Squinting Face - Works the orbital muscles
        EmojiChallenge(emoji: "😑", name: "Squint Hard", check: { anchor in
            let squintL = anchor.blendShapes[.eyeSquintLeft]?.floatValue ?? 0
            let squintR = anchor.blendShapes[.eyeSquintRight]?.floatValue ?? 0
            return squintL > 0.7 && squintR > 0.7
        }),
        // 10. Wide Mouth Smile - Focuses on lateral movement
        EmojiChallenge(emoji: "😁", name: "Big Toothy Smile", check: { anchor in
            let stretchL = anchor.blendShapes[.mouthStretchLeft]?.floatValue ?? 0
            let stretchR = anchor.blendShapes[.mouthStretchRight]?.floatValue ?? 0
            return stretchL > 0.5 && stretchR > 0.5
        }),
        // 11. Sneering / Nose Scrunch
        EmojiChallenge(emoji: "😖", name: "Scrunch Nose", check: { anchor in
            let noseSneerL = anchor.blendShapes[.noseSneerLeft]?.floatValue ?? 0
            let noseSneerR = anchor.blendShapes[.noseSneerRight]?.floatValue ?? 0
            return noseSneerL > 0.6 && noseSneerR > 0.6
        }),
        // 12. Mouth Left - Lateral jaw/lip exercise
        EmojiChallenge(emoji: "😏", name: "Move Mouth Left", check: { anchor in
            let mouthLeft = anchor.blendShapes[.mouthLeft]?.floatValue ?? 0
            return mouthLeft > 0.6
        }),
        // 13. Move Mouth Right - Lateral jaw/lip exercise
                EmojiChallenge(emoji: "😒", name: "Move Mouth Right", check: { anchor in
                    let mouthRight = anchor.blendShapes[.mouthRight]?.floatValue ?? 0
                    return mouthRight > 0.6
                }),
                // 14. Wink Right Eye - Isolates opposite facial control
                EmojiChallenge(emoji: "😜", name: "Wink Right Eye", check: { anchor in
                    let eyeCloseL = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
                    let eyeCloseR = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0
                    return eyeCloseR > 0.8 && eyeCloseL < 0.2
                }),
                // 15. Sad Face / Pouting - Targets the chin (Mentalis) muscle
                EmojiChallenge(emoji: "☹️", name: "Pout", check: { anchor in
                    let frownL = anchor.blendShapes[.mouthFrownLeft]?.floatValue ?? 0
                    let frownR = anchor.blendShapes[.mouthFrownRight]?.floatValue ?? 0
                    let puckerLower = anchor.blendShapes[.mouthLowerDownLeft]?.floatValue ?? 0
                    return frownL > 0.5 && frownR > 0.5 || puckerLower > 0.4
                }),
                
                EmojiChallenge(emoji: "😗", name: "Suck in Cheeks", check: { anchor in
                    let cheekSuck = anchor.blendShapes[.cheekPuff]?.floatValue ?? 0
                    // Note: ARKit uses negative values or specific shapes for suction depending on version;
                    // mouthPress is often a good proxy for the internal tension.
                    let pressL = anchor.blendShapes[.mouthPressLeft]?.floatValue ?? 0
                    let pressR = anchor.blendShapes[.mouthPressRight]?.floatValue ?? 0
                    return pressL > 0.6 && pressR > 0.6
                }),
                // 19. Open Mouth Wide - Jaw range of motion
                EmojiChallenge(emoji: "😫", name: "Wide Open Jaw", check: { anchor in
                    let jawOpen = anchor.blendShapes[.jawOpen]?.floatValue ?? 0
                    return jawOpen > 0.85
                }),
                // 20. Lip Press - Strengthening the orbicularis oris
                EmojiChallenge(emoji: "😐", name: "Press Lips Tight", check: { anchor in
                    let pressL = anchor.blendShapes[.mouthPressLeft]?.floatValue ?? 0
                    let pressR = anchor.blendShapes[.mouthPressRight]?.floatValue ?? 0
                    return pressL > 0.7 && pressR > 0.7
                }),
                // 21. Dimple/Cheek Tighten - Targets the buccinator
                EmojiChallenge(emoji: "😏", name: "Tighten Cheeks", check: { anchor in
                    let dimpleL = anchor.blendShapes[.cheekSquintLeft]?.floatValue ?? 0
                    let dimpleR = anchor.blendShapes[.cheekSquintRight]?.floatValue ?? 0
                    return dimpleL > 0.5 && dimpleR > 0.5
                }),
                
            
    ]
}
