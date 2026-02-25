//
//  WalkingSteadinessChartView.swift
//  Parkinsons
//
//  Created by SDC-USER on 18/02/26.
//
import UIKit

class WalkingSteadinessChartView: UIView {

    private var points: [(date: Date, value: Double)] = []

    func configure(with data: [(date: Date, value: Double)]) {
        self.points = data
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard points.count > 0 else { return }

        guard let context = UIGraphicsGetCurrentContext() else { return }

        let width = rect.width
        let height = rect.height

        let maxValue = 100.0
        let barWidth = width / CGFloat(points.count * 2)

        for (index, point) in points.enumerated() {

            let x = CGFloat(index * 2) * barWidth
            let barHeight = CGFloat(point.value / maxValue) * height
            let y = height - barHeight

            let barRect = CGRect(x: x,
                                 y: y,
                                 width: barWidth,
                                 height: barHeight)

            context.setFillColor(UIColor.systemBlue.cgColor)
            context.fill(barRect)
        }

        drawAxes(in: context, rect: rect)
    }

    private func drawAxes(in context: CGContext, rect: CGRect) {

        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(1)

        // X axis
        context.move(to: CGPoint(x: 0, y: rect.height))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height))

        // Y axis
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: 0, y: rect.height))

        context.strokePath()
    }
}

