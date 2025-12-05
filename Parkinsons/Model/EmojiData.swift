//
//  EmojiData.swift
//  Parkinsons
//
//  Created by SDC-USER on 05/12/25.
//

import Foundation
import SwiftUI



enum faces: CaseIterable {
    case Angry_face, Anguished_face, Anxious_face_with_sweat, Astonished_face, Beaming_face_with_smiling_eyes, Cat, Clown_face, Cold_face, Confounded_face, Cowboy_hat_face, Crying_face, Disappointed_face, Dizzy_face, Downcast_face_with_sweat, Drooling_face, Exploding_head, Expressionless_face, Face_blowing_a_kiss, Face_savoring_food, Face_screaming_in_fear, Face_with_head_bandage, Face_with_monocle, Face_with_open_mouth, Face_with_raised_eyebrow, Face_with_rolling_eyes, Face_with_steam_from_nose, Face_with_tears_of_joy, Face_with_thermometer, Face_with_tongue, Fearful_face, Flushed_face, Frowning_face_with_open_mouth, Frowning_face, Grimacing_face, Grinning_face_with_big_eyes, Grinning_face_with_sweat, Grinning_face_1, Grinning_face, Grinning_squinting_face, Hot_face, Hushed_face, Joker, Kissing_face_with_closed_eyes, Kissing_face_with_smiling_eyes, Kissing_face, Lion, Loudly_crying_face, Money_mouth_face_$, Monkey, Nauseated_face, Nerd_face, Neutral_face, Panda, Pensive_face, Pile_of_poo, Pleading_face, Pouting_face, Relieved_face, Rolling_on_the_floor_laughing, Sad_but_relieved_face, Santa_Claus, Sleep_face, Sleepy_face, Slightly_frowning_face, Slightly_smiling_face, Smiling_face_with_halo, Smiling_face_with_heart_eyes, Smiling_face_with_hearts, Smiling_face_with_smiling_eyes, Smiling_face, Squinting_face_with_tongue, Star_struck, Thinking_face, Tired_face, Vomiting_face, Weary_face, Winking_face_with_tongue, Winking_face, Worried_face_1, Worried_face
    
    
    var image: Image {
        switch self {
        case .Angry_face: return Image("Angry face")
        case .Anguished_face:
            return Image("Anguished face")
        case .Anxious_face_with_sweat:
            return Image("Anxious face with sweat")
        case .Astonished_face:
            return Image("Astonished face")
        case .Beaming_face_with_smiling_eyes:
            return Image("Beaming face with smiling eyes")
        case .Cat:
            return Image("Cat")
        case .Clown_face:
            return Image("Clown face")
        case .Cold_face:
            return Image("Cold face")
        case .Confounded_face:
            return Image("Confounded face")
        case .Cowboy_hat_face:
            return Image("Cowboy hat face")
        case .Crying_face:
            return Image("Crying face")
        case .Disappointed_face:
            return Image("Disappointed face")
        case .Dizzy_face:
            return Image("Dizzy face")
        case .Downcast_face_with_sweat:
            return Image("Downcast face with sweat")
        case .Drooling_face:
            return Image("Drooling face")
        case .Exploding_head:
            return Image("Exploding head")
        case .Expressionless_face:
            return Image("Expressionless face")
        case .Face_blowing_a_kiss:
            return Image("Face blowing a kiss")
        case .Face_savoring_food:
            return Image("Face savoring food")
        case .Face_screaming_in_fear:
            return Image("Face screaming in fear")
        case .Face_with_head_bandage:
            return Image("Face with head-bandage")
        case .Face_with_monocle:
            return Image("Face with monocle")
        case .Face_with_open_mouth:
            return Image("Face with open mouth")
        case .Face_with_raised_eyebrow:
            return Image("Face with raised eyebrow")
        case .Face_with_rolling_eyes:
            return Image("Face with rolling eyes")
        case .Face_with_steam_from_nose:
            return Image("Face with steam from nose")
        case .Face_with_tears_of_joy:
            return Image("Face with tears of joy")
        case .Face_with_thermometer:
            return Image("Face with thermometer")
        case .Face_with_tongue:
            return Image("Face with tongue")
        case .Fearful_face:
            return Image("Fearful face")
        case .Flushed_face:
            return Image("Flushed face")
        case .Frowning_face_with_open_mouth:
            return Image("Frowning face with open mouth")
        case .Frowning_face:
            return Image("Frowning face")
        case .Grimacing_face:
            return Image("Grimacing face")
        case .Grinning_face_with_big_eyes:
            return Image("Grinning face with big eyes")
        case .Grinning_face_with_sweat:
            return Image("Grinning face with sweat")
        case .Grinning_face_1:
            return Image("Grinning face-1")
        case .Grinning_face:
            return Image("Grinning face")
        case .Grinning_squinting_face:
            return Image("Grinning squinting face")
        case .Hot_face:
            return Image("Hot face")
        case .Hushed_face:
            return Image("Hushed face")
        case .Joker:
            return Image("Joker")
        case .Kissing_face_with_closed_eyes:
            return Image("Kissing face with closed eyes")
        case .Kissing_face_with_smiling_eyes:
            return Image("Kissing face with smiling eyes")
        case .Kissing_face:
            return Image("Kissing face")
        case .Lion:
            return Image("Lion")
        case .Loudly_crying_face:
            return Image("Loudly crying face")
        case .Money_mouth_face_$:
            return Image("Money mouth face $")
        case .Monkey:
            return Image("Monkey")
        case .Nauseated_face:
            return Image("Nauseated face")
        case .Nerd_face:
            return Image("Nerd face")
        case .Neutral_face:
            return Image("Neutral face")
        case .Panda:
            return Image("Panda")
        case .Pensive_face:
            return Image("Pensive face")
        case .Pile_of_poo:
            return Image("Pile of poo")
        case .Pleading_face:
            return Image("Pleading face")
        case .Pouting_face:
            return Image("Pouting face")
        case .Relieved_face:
            return Image("Relieved face")
        case .Rolling_on_the_floor_laughing:
            return Image("Rolling on the floor laughing")
        case .Sad_but_relieved_face:
            return Image("Sad but relieved face")
        case .Santa_Claus:
            return Image("Santa Claus")
        case .Sleep_face:
            return Image("Sleep face")
        case .Sleepy_face:
            return Image("Sleepy face")
        case .Slightly_frowning_face:
            return Image("Slightly frowning face")
        case .Slightly_smiling_face:
            return Image("Slightly smiling face")
        case .Smiling_face_with_halo:
            return Image("Smiling face with halo")
        case .Smiling_face_with_heart_eyes:
            return Image("Smiling face with heart-eyes")
        case .Smiling_face_with_hearts:
            return Image("Smiling face with hearts")
        case .Smiling_face_with_smiling_eyes:
            return Image("Smiling face with smiling eyes")
        case .Smiling_face:
            return Image("Smiling face")
        case .Squinting_face_with_tongue:
            return Image("Squinting face with tongue")
        case .Star_struck:
            return Image("Star-struck")
        case .Thinking_face:
            return Image("Thinking face")
        case .Tired_face:
            return Image("Tired face")
        case .Vomiting_face:
            return Image("Vomiting face")
        case .Weary_face:
            return Image("Weary face")
        case .Winking_face_with_tongue:
            return Image("Winking face with tongue")
        case .Winking_face:
            return Image("Winking face")
        case .Worried_face_1:
            return Image("Worried face-1")
        case .Worried_face:
            return Image("Worried face")
        }
    }
    
    var eyeScale: Array<eyeScale> {
        switch self {
        case .Angry_face: return [.neutral, .squinting]
        case .Anguished_face: return [.neutral, .wideOpen]
        case .Anxious_face_with_sweat:
            return [.neutral, .wideOpen]
        case .Astonished_face:
            return [.wideOpen]
        case .Beaming_face_with_smiling_eyes:
            return [.squinting, .closed]
        case .Cat:
            return [.neutral, .wideOpen]
        case .Clown_face:
            return [.neutral, .wideOpen]
        case .Cold_face:
            return [.neutral, .wideOpen]
        case .Confounded_face:
            return [.squinting, .closed]
        case .Cowboy_hat_face:
            return [.neutral, .wideOpen]
        case .Crying_face:
            return [.neutral, .squinting]
        case .Disappointed_face:
            return [.closed]
        case .Dizzy_face:
            return [.closed, .wideOpen]
        case .Downcast_face_with_sweat:
            return [.closed]
        case .Drooling_face:
            return [.closed]
        case .Exploding_head:
            return [.neutral, .wideOpen]
        case .Expressionless_face:
            return [.neutral, .closed]
        case .Face_blowing_a_kiss:
            return [.wink]
        case .Face_savoring_food:
            return [.closed]
        case .Face_screaming_in_fear:
            return [.wideOpen]
        case .Face_with_head_bandage:
            return [.neutral]
        case .Face_with_monocle:
            return [.neutral, .squinting]
        case .Face_with_open_mouth:
            return [.wideOpen]
        case .Face_with_raised_eyebrow:
            return [.neutral, .squinting]
        case .Face_with_rolling_eyes:
            return [.rollingEyesUp]
        case .Face_with_steam_from_nose:
            return [.closed]
        case .Face_with_tears_of_joy:
            return [.closed]
        case .Face_with_thermometer:
            return [.neutral]
        case .Face_with_tongue:
            return [.neutral]
        case .Fearful_face:
            return [.wideOpen, .neutral]
        case .Flushed_face:
            return [.wideOpen]
        case .Frowning_face_with_open_mouth:
            return [.wideOpen, .neutral]
        case .Frowning_face:
            return [.neutral]
        case .Grimacing_face:
            return [.neutral, .wideOpen]
        case .Grinning_face_with_big_eyes:
            return [.neutral, .wideOpen]
        case .Grinning_face_with_sweat:
            return [.closed]
        case .Grinning_face_1:
            return [.closed]
        case .Grinning_face:
            return [.neutral]
        case .Grinning_squinting_face:
            return [.closed]
        case .Hot_face:
            return [.neutral, .wideOpen]
        case .Hushed_face:
            return [.wideOpen, .neutral]
        case .Joker:
            return [.neutral]
        case .Kissing_face_with_closed_eyes:
            return [.closed]
        case .Kissing_face_with_smiling_eyes:
            return [.closed]
        case .Kissing_face:
            return [.neutral]
        case .Lion:
            return [.neutral, .wideOpen]
        case .Loudly_crying_face:
            return [.closed]
        case .Money_mouth_face_$:
            return [.neutral, .wideOpen]
        case .Monkey:
            return [.neutral, .wideOpen]
        case .Nauseated_face:
            return [.neutral, .squinting, .wideOpen]
        case .Nerd_face:
            return [.neutral]
        case .Neutral_face:
            return [.neutral]
        case .Panda:
            return [.neutral, .wideOpen]
        case .Pensive_face:
            return [.closed]
        case .Pile_of_poo:
            return [.wideOpen]
        case .Pleading_face:
            return [.wideOpen]
        case .Pouting_face:
            return [.neutral, .squinting]
        case .Relieved_face:
            return [.closed]
        case .Rolling_on_the_floor_laughing:
            return [.closed]
        case .Sad_but_relieved_face:
            return [.neutral, .squinting]
        case .Santa_Claus:
            return [.wink]
        case .Sleep_face:
            return [.closed]
        case .Sleepy_face:
            return [.closed]
        case .Slightly_frowning_face:
            return [.neutral]
        case .Slightly_smiling_face:
            return [.neutral]
        case .Smiling_face_with_halo:
            return [.closed]
        case .Smiling_face_with_heart_eyes:
            return [.wideOpen]
        case .Smiling_face_with_hearts:
            return [.closed]
        case .Smiling_face_with_smiling_eyes:
            return [.closed]
        case .Smiling_face:
            return [.closed]
        case .Squinting_face_with_tongue:
            return [.closed]
        case .Star_struck:
            return [.wideOpen]
        case .Thinking_face:
            return [.neutral, .squinting]
        case .Tired_face:
            return [.closed]
        case .Vomiting_face:
            return [.closed]
        case .Weary_face:
            return [.closed]
        case .Winking_face_with_tongue:
            return [.wink]
        case .Winking_face:
            return [.wink]
        case .Worried_face_1:
            return [.neutral, .wideOpen]
        case .Worried_face:
            return [.neutral]
        }
    }
        
        var mouthScale: Array<mouthScale> {
            switch self {
            case .Angry_face:
                return [.frown]
            case .Anguished_face:
                return [.frown, .openMouthNeutral]
            case .Anxious_face_with_sweat:
                return [.frown]
            case .Astonished_face:
                return [.openMouthNeutral]
            case .Beaming_face_with_smiling_eyes:
                return [.openMouthSmile]
            case .Cat:
                return [.tongueOut]
            case .Clown_face:
                return [.openMouthSmile]
            case .Cold_face:
                return [.openMouthNeutral]
            case .Confounded_face:
                return [.frown]
            case .Cowboy_hat_face:
                return [.openMouthSmile]
            case .Crying_face:
                return [.frown]
            case .Disappointed_face:
                return [.frown]
            case .Dizzy_face:
                return [.openMouthNeutral]
            case .Downcast_face_with_sweat:
                return [.frown]
            case .Drooling_face:
                return [.smile]
            case .Exploding_head:
                return [.openMouthNeutral, .frown]
            case .Expressionless_face:
                return [.neutral]
            case .Face_blowing_a_kiss:
                return [.kissFace]
            case .Face_savoring_food:
                return [.tongueOut, .smile]
            case .Face_screaming_in_fear:
                return [.openMouthNeutral]
            case .Face_with_head_bandage:
                return [.frown]
            case .Face_with_monocle:
                return [.frown, .neutral]
            case .Face_with_open_mouth:
                return [.openMouthNeutral]
            case .Face_with_raised_eyebrow:
                return [.neutral]
            case .Face_with_rolling_eyes:
                return [.neutral, .frown]
            case .Face_with_steam_from_nose:
                return [.frown]
            case .Face_with_tears_of_joy:
                return [.openMouthSmile]
            case .Face_with_thermometer:
                return [.frown]
            case .Face_with_tongue:
                return [.tongueOut]
            case .Fearful_face:
                return [.frown, .openMouthNeutral]
            case .Flushed_face:
                return [.neutral]
            case .Frowning_face_with_open_mouth:
                return [.frown, .openMouthNeutral]
            case .Frowning_face:
                return [.frown]
            case .Grimacing_face:
                return [.openMouthNeutral]
            case .Grinning_face_with_big_eyes:
                return [.openMouthSmile]
            case .Grinning_face_with_sweat:
                return [.openMouthSmile]
            case .Grinning_face_1:
                return [.openMouthSmile]
            case .Grinning_face:
                return [.openMouthSmile]
            case .Grinning_squinting_face:
                return [.openMouthSmile]
            case .Hot_face:
                return [.tongueOut]
            case .Hushed_face:
                return [.openMouthNeutral]
            case .Joker:
                return [.smile]
            case .Kissing_face_with_closed_eyes:
                return [.kissFace]
            case .Kissing_face_with_smiling_eyes:
                return [.kissFace]
            case .Kissing_face:
                return [.kissFace]
            case .Lion:
                return [.tongueOut]
            case .Loudly_crying_face:
                return [.openMouthNeutral, .frown]
            case .Money_mouth_face_$:
                return [.tongueOut]
            case .Monkey:
                return [.openMouthSmile]
            case .Nauseated_face:
                return [.frown]
            case .Nerd_face:
                return [.smile]
            case .Neutral_face:
                return [.neutral]
            case .Panda:
                return [.tongueOut]
            case .Pensive_face:
                return [.neutral]
            case .Pile_of_poo:
                return [.smile]
            case .Pleading_face:
                return [.neutral]
            case .Pouting_face:
                return [.frown]
            case .Relieved_face:
                return [.smile]
            case .Rolling_on_the_floor_laughing:
                return [.openMouthSmile]
            case .Sad_but_relieved_face:
                return [.frown]
            case .Santa_Claus:
                return [.smile, .openMouthSmile]
            case .Sleep_face:
                return [.openMouthNeutral]
            case .Sleepy_face:
                return [.frown, .openMouthNeutral]
            case .Slightly_frowning_face:
                return [.frown]
            case .Slightly_smiling_face:
                return [.smile]
            case .Smiling_face_with_halo:
                return [.smile]
            case .Smiling_face_with_heart_eyes:
                return [.openMouthSmile]
            case .Smiling_face_with_hearts:
                return [.smile, .openMouthSmile]
            case .Smiling_face_with_smiling_eyes:
                return [.smile]
            case .Smiling_face:
                return [.smile, .openMouthSmile]
            case .Squinting_face_with_tongue:
                return [.tongueOut]
            case .Star_struck:
                return [.openMouthSmile]
            case .Thinking_face:
                return [.frown, .neutral]
            case .Tired_face:
                return [.openMouthNeutral]
            case .Vomiting_face:
                return [.openMouthNeutral]
            case .Weary_face:
                return [.openMouthNeutral]
            case .Winking_face_with_tongue:
                return [.tongueOut]
            case .Winking_face:
                return [.smile, .openMouthSmile]
            case .Worried_face_1:
                return [.frown, .openMouthNeutral]
            case .Worried_face:
                return [.frown]
            }
    }
    
    var eyebrowScale: Array<eyebrowScale> {
        switch self {
        case .Angry_face:
            return [.furrowed]
        case .Anguished_face:
            return [.surprised]
        case .Anxious_face_with_sweat:
            return [.neutral, .surprised]
        case .Astonished_face:
            return [.surprised, .neutral]
        case .Beaming_face_with_smiling_eyes:
            return [.neutral]
        case .Cat:
            return [.neutral, .surprised]
        case .Clown_face:
            return [.neutral, .surprised]
        case .Cold_face:
            return [.neutral, .surprised]
        case .Confounded_face:
            return [.neutral, .furrowed]
        case .Cowboy_hat_face:
            return [.neutral, .surprised]
        case .Crying_face:
            return [.neutral, .surprised]
        case .Disappointed_face:
            return [.neutral, .furrowed]
        case .Dizzy_face:
            return [.neutral, .surprised]
        case .Downcast_face_with_sweat:
            return [.neutral, .furrowed]
        case .Drooling_face:
            return [.neutral, .surprised]
        case .Exploding_head:
            return [.surprised]
        case .Expressionless_face:
            return [.neutral]
        case .Face_blowing_a_kiss:
            return [.splitSkeptical]
        case .Face_savoring_food:
            return [.neutral, .surprised]
        case .Face_screaming_in_fear:
            return [.surprised]
        case .Face_with_head_bandage:
            return [.neutral]
        case .Face_with_monocle:
            return [.splitSkeptical, .furrowed]
        case .Face_with_open_mouth:
            return [.surprised]
        case .Face_with_raised_eyebrow:
            return [.splitSkeptical]
        case .Face_with_rolling_eyes:
            return [.surprised, .neutral]
        case .Face_with_steam_from_nose:
            return [.furrowed, .neutral, .surprised]
        case .Face_with_tears_of_joy:
            return [.neutral, .furrowed, .surprised]
        case .Face_with_thermometer:
            return [.neutral]
        case .Face_with_tongue:
            return [.neutral, .surprised]
        case .Fearful_face:
            return [.surprised, .neutral]
        case .Flushed_face:
            return [.surprised, .neutral]
        case .Frowning_face_with_open_mouth:
            return [.surprised, .neutral]
        case .Frowning_face:
            return [.neutral, .furrowed]
        case .Grimacing_face:
            return [.neutral, .surprised]
        case .Grinning_face_with_big_eyes:
            return [.neutral, .surprised]
        case .Grinning_face_with_sweat:
            return [.surprised, .neutral]
        case .Grinning_face_1:
            return [.surprised, .neutral]
        case .Grinning_face:
            return [.neutral, .surprised]
        case .Grinning_squinting_face:
            return [.surprised, .neutral]
        case .Hot_face:
            return [.surprised, .neutral]
        case .Hushed_face:
            return [.surprised]
        case .Joker:
            return [.neutral, .surprised]
        case .Kissing_face_with_closed_eyes:
            return [.neutral, .surprised]
        case .Kissing_face_with_smiling_eyes:
            return [.neutral, .surprised]
        case .Kissing_face:
            return [.neutral]
        case .Lion:
            return [.neutral, .surprised]
        case .Loudly_crying_face:
            return [.furrowed, .neutral]
        case .Money_mouth_face_$:
            return [.neutral, .surprised]
        case .Monkey:
            return [.neutral, .surprised]
        case .Nauseated_face:
            return [.furrowed, .neutral]
        case .Nerd_face:
            return [.neutral, .surprised]
        case .Neutral_face:
            return [.neutral]
        case .Panda:
            return [.neutral, .surprised]
        case .Pensive_face:
            return [.neutral, .furrowed]
        case .Pile_of_poo:
            return [.neutral, .surprised]
        case .Pleading_face:
            return [.neutral, .surprised]
        case .Pouting_face:
            return [.furrowed]
        case .Relieved_face:
            return [.neutral, .surprised]
        case .Rolling_on_the_floor_laughing:
            return [.surprised, .neutral]
        case .Sad_but_relieved_face:
            return [.furrowed, .neutral]
        case .Santa_Claus:
            return [.splitSkeptical]
        case .Sleep_face:
            return [.neutral, .surprised]
        case .Sleepy_face:
            return [.neutral, .surprised]
        case .Slightly_frowning_face:
            return [.neutral]
        case .Slightly_smiling_face:
            return [.neutral]
        case .Smiling_face_with_halo:
            return [.neutral, .surprised]
        case .Smiling_face_with_heart_eyes:
            return [.surprised, .neutral]
        case .Smiling_face_with_hearts:
            return [.neutral, .surprised]
        case .Smiling_face_with_smiling_eyes:
            return [.neutral, .surprised]
        case .Smiling_face:
            return [.neutral, .surprised]
        case .Squinting_face_with_tongue:
            return [.neutral, .surprised]
        case .Star_struck:
            return [.surprised, .neutral]
        case .Thinking_face:
            return [.splitSkeptical, .furrowed]
        case .Tired_face:
            return [.furrowed, .neutral]
        case .Vomiting_face:
            return [.furrowed, .surprised, .neutral]
        case .Weary_face:
            return [.furrowed, .surprised, .neutral]
        case .Winking_face_with_tongue:
            return [.splitSkeptical]
        case .Winking_face:
            return [.splitSkeptical]
        case .Worried_face_1:
            return [.neutral, .surprised]
        case .Worried_face:
            return [.neutral]
        }
    }
    
}

enum eyebrowScale: CaseIterable {
    case neutral, surprised, furrowed, splitSkeptical
    
    var string: String {
        switch self {
        case .neutral: return "Neutral"
        case .surprised:
            return "Suprised"
        case .furrowed:
            return "Furrowed"
        case .splitSkeptical:
            return "Skeptical"
        }
    }
}


enum eyeScale: CaseIterable {
    case neutral, closed, wideOpen, rollingEyesUp, squinting, wink
    
    var string: String {
        switch self {
        case .neutral:
            return "Neutral"
        case .closed:
            return "Closed"
        case .wideOpen:
            return "Wide Open"
        case .rollingEyesUp:
            return "Rolling Eyes Up"
        case .squinting:
            return "Squinting"
        case .wink:
            return "Winking"
        }
    }
}

enum mouthScale: CaseIterable {
    case neutral, smile, frown, openMouthSmile, openMouthNeutral, tongueOut, kissFace
    
    var string: String {
        switch self {
        case .neutral: return "Neutral"
        case .smile:
            return "Smile"
        case .frown:
            return "Frown"
        case .openMouthSmile:
            return "Open Mouth Smile"
        case .openMouthNeutral:
            return "Open Mouth Neutral"
        case .tongueOut:
            return "Tongue Out"
        case .kissFace:
            return "Kiss Face"
        }
    }
}



enum StorageKeys: String {
    case endingHighestScore, endingLowestTime
}
