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


import UIKit
import Foundation

struct TherapeuticGameModel {
    let title: String
    let description: String
    let iconName: String?
    let iconColor: UIColor
    /// e.g. (completed: 1, total: 31). When non-nil, shows the badge instead of plain description.
    let progress: (completed: Int, total: Int)?

    init(title: String, description: String, iconName: String?, iconColor: UIColor, progress: (completed: Int, total: Int)? = nil) {
        self.title = title
        self.description = description
        self.iconName = iconName
        self.iconColor = iconColor
        self.progress = progress
    }
}
