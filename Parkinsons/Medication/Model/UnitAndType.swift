//
//  UnitAndType.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import Foundation

struct UnitAndType {
    var name: String
    var image: String
    var isSelected: Bool
}

var unitAndType: [UnitAndType] = [
    UnitAndType(name: "Capsule", image: "capsuleM", isSelected: false),
    UnitAndType(name: "Tablet", image: "tablet", isSelected: false),
    UnitAndType(name: "Liquid", image: "liquid", isSelected: false),
    UnitAndType(name: "Cream", image: "cream", isSelected: false),
    UnitAndType(name: "Device", image: "device", isSelected: false),
    UnitAndType(name: "Drops", image: "drops", isSelected: false),
    UnitAndType(name: "Foam", image: "foam", isSelected: false),
    UnitAndType(name: "Gel", image: "gel", isSelected: false),
    UnitAndType(name: "Powder", image: "powder", isSelected: false),
    UnitAndType(name: "Spray", image: "spray", isSelected: false)
]
