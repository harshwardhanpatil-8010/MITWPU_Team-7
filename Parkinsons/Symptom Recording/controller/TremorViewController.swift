//
//  TremorViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 05/01/26.
//

import UIKit
struct AggregatedTremorPoint {
    let date: Date
    let avgHz: Double
}

class TremorViewController: UIViewController {

    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var tremorFreq: UILabel!
    @IBOutlet weak var TremorGraphView: UIView!
    @IBOutlet weak var TremorSegmentControl: UISegmentedControl!
    @IBOutlet weak var TremorCardView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        TremorCardView.applyCardStyle()
        setupNavigationBar()
        updateTremorUI(for: .day)
    }

    private func setupNavigationBar() {
        title = "Tremors"
    }

    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let range: TremorRange

        switch sender.selectedSegmentIndex {
        case 0:
            range = .day
        case 1:
            range = .week
        case 2:
            range = .month
        case 3:
            range = .sixMonth
        case 4:
            range = .year
        default:
            return
        }

        updateTremorUI(for: range)
    }
    private func aggregateSamples(_ samples: [TremorSample],
                                  for range: TremorRange) -> [AggregatedTremorPoint] {

        let calendar = Calendar.current

        switch range {

        // MARK: - DAY (raw data)
        case .day:
            return samples.map {
                AggregatedTremorPoint(date: $0.date, avgHz: $0.frequencyHz)
            }

        // MARK: - WEEK → avg per day
        case .week:
            let grouped = Dictionary(grouping: samples) {
                calendar.startOfDay(for: $0.date)
            }

            return grouped
                .map { (day, samples) in
                    let avg = samples.map { $0.frequencyHz }.average()
                    return AggregatedTremorPoint(date: day, avgHz: avg)
                }
                .sorted { $0.date < $1.date }

        // MARK: - MONTH → avg per week
        case .month:
            let grouped = Dictionary(grouping: samples) {
                calendar.dateInterval(of: .weekOfYear, for: $0.date)!.start
            }

            return grouped
                .map { (weekStart, samples) in
                    let avg = samples.map { $0.frequencyHz }.average()
                    return AggregatedTremorPoint(date: weekStart, avgHz: avg)
                }
                .sorted { $0.date < $1.date }

        // MARK: - 6 MONTHS → avg per month
        case .sixMonth, .year:
            let grouped = Dictionary(grouping: samples) {
                calendar.date(from: calendar.dateComponents([.year, .month], from: $0.date))!
            }

            return grouped
                .map { (monthStart, samples) in
                    let avg = samples.map { $0.frequencyHz }.average()
                    return AggregatedTremorPoint(date: monthStart, avgHz: avg)
                }
                .sorted { $0.date < $1.date }
        }
    }

    private func updateTremorUI(for range: TremorRange) {

        let rawSamples = TremorDataStore.shared.fetchSamples(for: range)

        let aggregated = aggregateSamples(rawSamples, for: range)

        updateAverageLabel(using: rawSamples)   // card shows overall avg
        updateGraph(using: aggregated, range: range)
        updateDateLabel(for: range)
    }


    private func updateAverageLabel(using samples: [TremorSample]) {
        let avgHz = samples.averageFrequency()

        // Clamp for realistic medical UI
        let clampedHz = min(max(avgHz, 0), 12)

        if clampedHz > 0 {
            tremorFreq.text = String(format: "%.1f Hz", clampedHz)
        } else {
            tremorFreq.text = "—"
        }
    }
    private func xAxisLabels(for samples: [TremorSample],
                             range: TremorRange) -> [(index: Int, label: String)] {

        let calendar = Calendar.current
        var labels: [(Int, String)] = []

        switch range {

        case .day:
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"

            let labelCount = min(4, samples.count)

            for i in 0..<labelCount {
                let index = i * (samples.count - 1) / max(labelCount - 1, 1)
                labels.append((index, formatter.string(from: samples[index].date)))
            }

        case .week:
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"

            let uniqueDays = Dictionary(grouping: samples.indices) {
                calendar.startOfDay(for: samples[$0].date)
            }

            for (_, indices) in uniqueDays.sorted(by: { $0.key < $1.key }) {
                if let first = indices.first {
                    labels.append((first, formatter.string(from: samples[first].date)))
                }
            }

        case .month:
            let formatter = DateFormatter()
            formatter.dateFormat = "d"

            let targetDays: Set<Int> = [7, 14, 21, 28]

            for (i, sample) in samples.enumerated() {
                let day = calendar.component(.day, from: sample.date)
                if targetDays.contains(day) {
                    labels.append((i, formatter.string(from: sample.date)))
                }
            }

        case .sixMonth:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"

            let uniqueMonths = Dictionary(grouping: samples.indices) {
                calendar.component(.month, from: samples[$0].date)
            }

            for (_, indices) in uniqueMonths.sorted(by: { $0.key < $1.key }) {
                if let first = indices.first {
                    labels.append((first, formatter.string(from: samples[first].date)))
                }
            }

        case .year:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"

            let uniqueMonths = Dictionary(grouping: samples.indices) {
                calendar.component(.month, from: samples[$0].date)
            }

            for (_, indices) in uniqueMonths.sorted(by: { $0.key < $1.key }) {
                if let first = indices.first {
                    let month = formatter.string(from: samples[first].date)
                    labels.append((first, String(month.prefix(1))))
                }
            }
        }


        return labels
    }

    private func updateDateLabel(for range: TremorRange) {
        let formatter = DateFormatter()
        let now = Date()
        let calendar = Calendar.current

        switch range {

        case .day:
            formatter.dateFormat = "d MMM yyyy"
            DateLabel.text = formatter.string(from: now)

        case .week:
            let start = calendar.date(byAdding: .day, value: -6, to: now)!
            formatter.dateFormat = "d MMM"
            DateLabel.text = "\(formatter.string(from: start)) – \(formatter.string(from: now))"

        case .month:
            formatter.dateFormat = "MMMM yyyy"
            DateLabel.text = formatter.string(from: now)

        case .sixMonth:
            let start = calendar.date(byAdding: .month, value: -5, to: now)!
            formatter.dateFormat = "MMM yyyy"
            DateLabel.text = "\(formatter.string(from: start)) – \(formatter.string(from: now))"

        case .year:
            formatter.dateFormat = "yyyy"
            DateLabel.text = formatter.string(from: now)
        }
    }



    private func updateGraph(using points: [AggregatedTremorPoint],
                             range: TremorRange) {

        // ✅ Clear old graph layers (IMPORTANT)
        TremorGraphView.layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }

        guard samples.count > 1 else { return }

        let width = TremorGraphView.bounds.width
        let height = TremorGraphView.bounds.height

        let padding: CGFloat = 30
        let usableWidth = width - 2 * padding
        let usableHeight = height - 2 * padding

        let maxHz = max(samples.map { $0.frequencyHz }.max() ?? 6, 6)
        let minHz: Double = 0

        // MARK: - Y Axis (Hz labels + grid)
        let ySteps = 4
        for i in 0...ySteps {

            let value = minHz + (Double(i) / Double(ySteps)) * (maxHz - minHz)
            let normalizedY = CGFloat(i) / CGFloat(ySteps)
            let y = height - padding - normalizedY * usableHeight

            // Grid line
            let gridPath = UIBezierPath()
            gridPath.move(to: CGPoint(x: padding, y: y))
            gridPath.addLine(to: CGPoint(x: width, y: y))

            let gridLayer = CAShapeLayer()
            gridLayer.path = gridPath.cgPath
            gridLayer.strokeColor = UIColor.systemGray5.cgColor
            gridLayer.lineWidth = 1
            TremorGraphView.layer.addSublayer(gridLayer)

            // Y-axis label
            let label = CATextLayer()
            label.string = String(format: "%.0f", value)
            label.fontSize = 10
            label.foregroundColor = UIColor.secondaryLabel.cgColor
            label.frame = CGRect(x: 0, y: y - 6, width: padding - 4, height: 12)
            label.alignmentMode = .right
            label.contentsScale = UIScreen.main.scale
            TremorGraphView.layer.addSublayer(label)
        }

        // MARK: - X Axis labels
        // MARK: - X Axis labels (RANGE-AWARE ✅)
        let labels = xAxisLabels(for: samples, range: TremorSegmentControl.selectedSegmentIndex == 0 ? .day :
                                                    TremorSegmentControl.selectedSegmentIndex == 1 ? .week :
                                                    TremorSegmentControl.selectedSegmentIndex == 2 ? .month :
                                                    TremorSegmentControl.selectedSegmentIndex == 3 ? .sixMonth :
                                                    .year)

        for item in labels {

            let normalizedX = CGFloat(item.index) / CGFloat(samples.count - 1)
            let x = padding + normalizedX * usableWidth

            let label = CATextLayer()
            label.string = item.label
            label.fontSize = 10
            label.foregroundColor = UIColor.secondaryLabel.cgColor
            label.frame = CGRect(x: x - 20,
                                  y: height - padding + 6,
                                  width: 40,
                                  height: 14)
            label.alignmentMode = .center
            label.contentsScale = UIScreen.main.scale

            TremorGraphView.layer.addSublayer(label)
        }


        // MARK: - Tremor line (DYNAMIC SCALING)
        let path = UIBezierPath()

        for (i, sample) in samples.enumerated() {

            let normalizedX = CGFloat(i) / CGFloat(samples.count - 1)
            let normalizedY = CGFloat((sample.frequencyHz - minHz) / (maxHz - minHz))

            let x = padding + normalizedX * usableWidth
            let y = height - padding - normalizedY * usableHeight

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.systemBlue.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 2
        lineLayer.lineJoin = .round
        lineLayer.lineCap = .round

        TremorGraphView.layer.addSublayer(lineLayer)
    }




}

extension Array where Element == Double {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
