//
//  TremorRange.swift
//  Parkinsons
//
//  Created by SDC-USER on 03/02/26.
//
import Foundation
enum TremorRange {
    case day
    case week
    case month
    case sixMonth
    case year
}
extension Array where Element == TremorSample {
    /// Returns average frequency in Hz
    func averageFrequency() -> Double {
        guard !self.isEmpty else { return 0 }
        let total = self.reduce(0) { $0 + $1.frequencyHz }
        return total / Double(self.count)
    }
}
