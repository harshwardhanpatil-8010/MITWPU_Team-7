//
//  HealthPermissionsData.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
/// Defines the data model for a single Health Permission setting.
struct HealthPermissionSetting {
    let iconName: String // System/Asset name for the image icon (e.g., "heart.fill")
    let labelText: String // The main text label (e.g., "Active Energy")
    var isEnabled: Bool // The current state of the switch (On/Off)
}
