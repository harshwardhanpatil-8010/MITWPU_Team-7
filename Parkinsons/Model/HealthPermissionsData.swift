//
//  HealthPermissionsData.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

/// Defines the data model for a single Health Permission setting.
struct HealthPermissionSetting {
    let iconName: String // System/Asset name for the image icon (e.g., "heart.fill")
    let labelText: String // The main text label (e.g., "Active Energy")
    var isEnabled: Bool // The current state of the switch (On/Off)
    var iconColor: UIColor? // Optional tint color for the icon

    init(iconName: String, labelText: String, isEnabled: Bool, iconColor: UIColor? = nil) {
        self.iconName = iconName
        self.labelText = labelText
        self.isEnabled = isEnabled
        self.iconColor = iconColor
    }
}

