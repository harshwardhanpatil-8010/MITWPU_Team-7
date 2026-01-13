//
//  DateExtension.swift
//  Parkinsons
//
//  Created by SDC-USER on 12/01/26.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
