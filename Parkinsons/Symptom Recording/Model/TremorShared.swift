//
//  TremorShared.swift
//  Parkinsons
//
//  Shared types used by TremorViewController, tremorCard, and SymptomViewController.
//

import Foundation

/// A bucketed tremor reading used for graph display.
struct AggregatedTremorPoint {
    let date: Date
    let avgHz: Double
}

extension Array where Element == Double {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
