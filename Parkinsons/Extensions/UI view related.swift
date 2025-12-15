//
//  UI view related.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
import UIKit

extension UIView {

    func applyCardStyle() {
        let cornerRadius: CGFloat = 40
        let shadowColor: UIColor = .black
        let shadowOpacity: Float = 0.15

        let shadowRadius: CGFloat = 3
        let shadowOffset: CGSize = .init(width: 0, height: 1)

        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false

        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
    }
}
