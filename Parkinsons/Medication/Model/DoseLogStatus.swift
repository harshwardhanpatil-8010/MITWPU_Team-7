//
//  DoseLogStatus.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 12/01/26.
//

import Foundation

enum DoseLogStatus {
    case none
    case taken
    case skipped
}

// MARK: - Mapping between UI & Stored status
extension DoseLogStatus {
    init(from status: DoseStatus) {
        switch status {
        case .none: self = .none
        case .taken: self = .taken
        case .skipped: self = .skipped
        }
    }
}

extension DoseStatus {
    init(from logStatus: DoseLogStatus) {
        switch logStatus {
        case .none: self = .none
        case .taken: self = .taken
        case .skipped: self = .skipped
        }
    }
}
