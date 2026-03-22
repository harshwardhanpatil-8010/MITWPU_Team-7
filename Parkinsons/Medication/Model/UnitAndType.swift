//
//  UnitAndType.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import Foundation

struct UnitAndType {//UI support model,Static
    var name: String
    var image: String
    var isSelected: Bool
}

var unitAndType: [UnitAndType] = [
    UnitAndType(name: "Capsule", image: "capsule1", isSelected: false),
    UnitAndType(name: "Tablet", image: "tablet1", isSelected: false),
    UnitAndType(name: "Liquid", image: "liquid1", isSelected: false),
    UnitAndType(name: "Cream", image: "cream1", isSelected: false),
    UnitAndType(name: "Device", image: "device1", isSelected: false),
    UnitAndType(name: "Drops", image: "drops1", isSelected: false),
    UnitAndType(name: "Foam", image: "foam1", isSelected: false),
    UnitAndType(name: "Gel", image: "gel1", isSelected: false),
    UnitAndType(name: "Powder", image: "powder1", isSelected: false),
    UnitAndType(name: "Spray", image: "spray1", isSelected: false)
]
extension UnitAndType {
    static func icon(for type: String) -> String {
        unitAndType.first {
            $0.name.lowercased() == type.lowercased()
        }?.image ?? "tablet"
    }
}

