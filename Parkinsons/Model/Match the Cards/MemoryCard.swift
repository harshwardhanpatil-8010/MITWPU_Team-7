//
//  File.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//


import Foundation

class MemoryCard {
    let id = UUID()
    var imageName: String
    var isFlipped = false
    var isMatched = false

    init(imageName: String) {
        self.imageName = imageName
    }
}

