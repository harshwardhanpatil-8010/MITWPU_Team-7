//
//  GaitViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 05/01/26.
//

import UIKit

class GaitViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var steadinessRange: UILabel!
    @IBOutlet weak var steadinessFreq: UILabel!
    @IBOutlet weak var walkingSteadinessGraph: UIView!

    @IBOutlet weak var GaitSegmentControl: UISegmentedControl!
    @IBOutlet weak var GaitCardView: UIView!
    private let chartView = WalkingSteadinessChartView()
    private var aggregatedPoints: [(date: Date, value: Double)] = []
    enum SteadinessRange {
        case day, week, month, sixMonth, year
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        GaitCardView.applyCardStyle()
        setupNavigationBar()
        setupChart()

        HealthKitManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                if granted {
                    self.fetchData(for: .day)
                } else {
                    print("HealthKit permission denied")
                }
            }
        }
    }

    private func setupChart() {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        walkingSteadinessGraph.addSubview(chartView)

        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: walkingSteadinessGraph.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: walkingSteadinessGraph.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: walkingSteadinessGraph.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: walkingSteadinessGraph.bottomAnchor)
        ])
    }



    private func setupNavigationBar() {
        title = "Walking Steadiness"
    }
    private func fetchData(for range: SteadinessRange) {

        let calendar = Calendar.current
        let now = Date()

        let startDate: Date = {
            switch range {
            case .day:
                return calendar.startOfDay(for: now)
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)!
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)!
            case .sixMonth:
                return calendar.date(byAdding: .month, value: -6, to: now)!
            case .year:
                return calendar.date(byAdding: .year, value: -1, to: now)!
            }
        }()

        HealthKitManager.shared.fetchWalkingSteadinessSamples(
            from: startDate,
            to: now
        ) { [weak self] samples in

            DispatchQueue.main.async {

                guard let self = self else { return }

                let grouped = Dictionary(grouping: samples) { sample in
                    calendar.startOfDay(for: sample.0)
                }

                self.aggregatedPoints = grouped.map { (date, values) in
                    let avg = values.map { $0.1 }.reduce(0, +) / Double(values.count)
                    return (date: date, value: avg)
                }
                .sorted { $0.date < $1.date }

                self.chartView.configure(with: self.aggregatedPoints)
            }
        }
    }



    @IBAction func segmentChanged(_ sender: UISegmentedControl) {

        let selectedRange: SteadinessRange

        switch sender.selectedSegmentIndex {
        case 0: selectedRange = .day
        case 1: selectedRange = .week
        case 2: selectedRange = .month
        case 3: selectedRange = .sixMonth
        case 4: selectedRange = .year
        default: selectedRange = .day
        }

        fetchData(for: selectedRange)
    }

}









