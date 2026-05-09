//
//  TherapeuticGameModel.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/12/25.
//
//
//import Foundation
//
//struct TherapeuticGameModel {
//    let title: String
//    let description: String
//    let iconName: String?
//}



import Foundation
import UIKit

struct TherapeuticGameModel {
    let title: String
    let description: String
    let iconName: String?
    let iconColor: UIColor
    let progress: (completed: Int, total: Int)?

    init(title: String, description: String, iconName: String?, iconColor: UIColor, progress: (completed: Int, total: Int)? = nil) {
        self.title = title
        self.description = description
        self.iconName = iconName
        self.iconColor = iconColor
        self.progress = progress
    }
}
