//
//  LevelManager.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//


import Foundation

class LevelManager {
    static let shared = LevelManager()

    private var availableAssets: [String] {
        return (1...32).map { "card_\($0)" }
    }

    func generateCards(for level: Int) -> [MemoryCard] {

        let pairs = min(3 + (level - 1), 16)

        let chosen = Array(availableAssets.shuffled().prefix(pairs))

        var cards: [MemoryCard] = []

        for name in chosen {
            cards.append(MemoryCard(imageName: name))
            cards.append(MemoryCard(imageName: name))
        }

        return cards.shuffled()
    }
}

