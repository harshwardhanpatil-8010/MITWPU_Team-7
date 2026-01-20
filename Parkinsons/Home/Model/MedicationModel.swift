//
//  MedicationModel.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//

import Foundation
struct MedicationModel {
    let name: String
    let time: String
    let detail: String 
    let iconName: String
    var status: DoseStatus = .none 
}
