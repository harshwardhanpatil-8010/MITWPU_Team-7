import UIKit
import HealthKit

class GaitViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var steadinessRange: UILabel!
    @IBOutlet weak var steadinessFreq: UILabel!
    @IBOutlet weak var walkingSteadinessGraph: UIView!
    @IBOutlet weak var GaitSegmentControl: UISegmentedControl!
    @IBOutlet weak var GaitCardView: UIView!

    private let chartView = WalkingSteadinessChartView()
    private var aggregatedPoints: [(date: Date, value: Double)] = []
    private var currentRange: SteadinessRange = .day
    private var pendingChartData: [(date: Date, value: Double)]? = nil  // cache when bounds not ready

    enum SteadinessRange { case day, week, month, sixMonth, year }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        GaitCardView.applyCardStyle()
        title = "Walking Steadiness"
        steadinessFreq.text = "Loading…"
        setupChart()
        walkingSteadinessGraph.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authorizeAndFetch()
    }

    // ✅ Chart configure() calls setNeedsDisplay which needs real bounds — draw here if deferred
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let data = pendingChartData {
            pendingChartData = nil
            chartView.configure(with: data)
        }
    }

    // MARK: - Chart Setup

    private func setupChart() {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .clear          // ✅ explicit clear
        chartView.isOpaque = false
        walkingSteadinessGraph.addSubview(chartView)
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: walkingSteadinessGraph.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: walkingSteadinessGraph.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: walkingSteadinessGraph.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: walkingSteadinessGraph.bottomAnchor),
        ])
    }

    // MARK: - Segment Control

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: currentRange = .day
        case 1: currentRange = .week
        case 2: currentRange = .month
        case 3: currentRange = .sixMonth
        case 4: currentRange = .year
        default: currentRange = .day
        }
        fetchData(for: currentRange)
    }

    // MARK: - Auth + Fetch

    private func authorizeAndFetch() {
        HealthKitManager.shared.requestAuthorization { [weak self] granted in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if granted {
                    self.fetchData(for: self.currentRange)
                } else {
                    self.showNoAccess()
                }
            }
        }
    }

    private func showNoAccess() {
        steadinessFreq.text  = "No Access"
        steadinessRange.text = "Enable Health access in Settings"
        chartView.configure(with: [])
    }

    // MARK: - Data Fetching

    private func fetchData(for range: SteadinessRange) {
        let cal = Calendar.current
        let now = Date()

        steadinessFreq.text  = "Loading…"
        steadinessRange.text = ""

        let start: Date = {
            switch range {
            case .day:      return cal.startOfDay(for: now)
            case .week:     return cal.date(byAdding: .day,   value: -7, to: now)!
            case .month:    return cal.date(byAdding: .month, value: -1, to: now)!
            case .sixMonth: return cal.date(byAdding: .month, value: -6, to: now)!
            case .year:     return cal.date(byAdding: .year,  value: -1, to: now)!
            }
        }()

        updateDateLabel(range: range, start: start, now: now)

        // ✅ Use .strictEndDate to avoid stale future-dated samples leaking in
        fetchNativeSteadiness(from: start, to: now, range: range) { [weak self] points in
            guard let self = self else { return }

            if !points.isEmpty {
                self.finalize(points: points)
            } else {
                // Fallback: compute from speed + step length
                self.fetchComputedSteadiness(from: start, to: now)
            }
        }
    }

    // MARK: - HealthKit: Native Apple Walking Steadiness

    private func fetchNativeSteadiness(
        from start: Date, to end: Date,
        range: SteadinessRange,
        completion: @escaping ([(date: Date, value: Double)]) -> Void
    ) {
        HealthKitManager.shared.fetchWalkingSteadinessSamples(from: start, to: end) { [weak self] rawSamples in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if rawSamples.isEmpty {
                    completion([])
                    return
                }
                // ✅ appleWalkingSteadiness returns 0.0–1.0 fraction — multiply by 100
                let samples = rawSamples.map { (date: $0.0, value: $0.1 * 100.0) }
                let aggregated = self.aggregate(samples: samples, range: range)
                completion(aggregated)
            }
        }
    }

    // MARK: - HealthKit: Computed Fallback

    private func fetchComputedSteadiness(from start: Date, to end: Date) {
        HealthKitManager.shared.fetchWalkingSteadiness(from: start, to: end) { [weak self] value in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let value = value {
                    self.finalize(points: [(date: Date(), value: value)])
                } else {
                    self.steadinessFreq.text  = "No Data"
                    self.steadinessRange.text = "Walk with your iPhone to collect data"
                    self.chartView.configure(with: [])
                }
            }
        }
    }

    // MARK: - Aggregation
    // Groups raw (date, value) pairs into buckets appropriate for the range

    private func aggregate(
        samples: [(date: Date, value: Double)],
        range: SteadinessRange
    ) -> [(date: Date, value: Double)] {
        let cal = Calendar.current

        let keyFor: (Date) -> Date = { d in
            switch range {
            case .day:
                // Bucket by hour for intra-day view
                var c = cal.dateComponents([.year, .month, .day, .hour], from: d)
                c.minute = 0; c.second = 0
                return cal.date(from: c) ?? d
            case .week:
                return cal.startOfDay(for: d)
            case .month:
                return cal.dateInterval(of: .weekOfYear, for: d)?.start ?? cal.startOfDay(for: d)
            case .sixMonth, .year:
                let c = cal.dateComponents([.year, .month], from: d)
                return cal.date(from: c) ?? cal.startOfDay(for: d)
            }
        }

        let grouped = Dictionary(grouping: samples) { keyFor($0.date) }
        return grouped
            .map { (date, vals) in
                (date: date, value: vals.map { $0.value }.reduce(0, +) / Double(vals.count))
            }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Finalize UI

    private func finalize(points: [(date: Date, value: Double)]) {
        aggregatedPoints = points

        // ✅ If bounds are ready, configure immediately; otherwise defer to viewDidLayoutSubviews
        if chartView.bounds.width > 0 {
            chartView.configure(with: points)
        } else {
            pendingChartData = points
        }

        guard !points.isEmpty else {
            steadinessFreq.text  = "No Data"
            steadinessRange.text = "—"
            return
        }

        let latest = points.last!.value

        UIView.transition(with: steadinessFreq, duration: 0.3, options: .transitionCrossDissolve) {
            self.steadinessFreq.text      = String(format: "%.0f / 100", latest)
            self.steadinessFreq.textColor = .black
        }

        let (label, _) = classificationFor(latest)
        UIView.transition(with: steadinessRange, duration: 0.3, options: .transitionCrossDissolve) {
            self.steadinessRange.text      = label
            self.steadinessRange.textColor = .black
        }
    }

    // MARK: - Helpers

    private func colorFor(_ v: Double) -> UIColor {
        if v >= 80 { return .systemGreen }
        if v >= 60 { return .systemYellow }
        return .systemRed
    }

    private func classificationFor(_ v: Double) -> (String, UIColor) {
        if v >= 80 { return ("Good",              .systemGreen)  }
        if v >= 60 { return ("Moderate",          .systemOrange) }
        return             ("Low — See a Doctor", .systemRed)
    }

    private func updateDateLabel(range: SteadinessRange, start: Date, now: Date) {
        let f = DateFormatter()
        switch range {
        case .day:
            f.dateFormat = "d MMM yyyy"
            dateLabel.text = f.string(from: now)
        case .week:
            f.dateFormat = "d MMM"
            dateLabel.text = "\(f.string(from: start)) – \(f.string(from: now))"
        case .month:
            f.dateFormat = "MMMM yyyy"
            dateLabel.text = f.string(from: now)
        case .sixMonth:
            f.dateFormat = "MMM yyyy"
            dateLabel.text = "\(f.string(from: start)) – \(f.string(from: now))"
        case .year:
            f.dateFormat = "yyyy"
            dateLabel.text = f.string(from: now)
        }
    }
}
