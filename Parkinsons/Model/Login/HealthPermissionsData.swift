//
//  HealthPermissionsData.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit


struct HealthPermissionSetting {
    let iconName: String
    let labelText: String
    var isEnabled: Bool
    var iconColor: UIColor?

    init(iconName: String, labelText: String, isEnabled: Bool, iconColor: UIColor? = nil) {
        self.iconName = iconName
        self.labelText = labelText
        self.isEnabled = isEnabled
        self.iconColor = iconColor
    }
}

