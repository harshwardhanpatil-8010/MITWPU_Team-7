





import UIKit
import HealthKit

class GaitViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var steadinessRange: UILabel!
    @IBOutlet weak var steadinessFreq: UILabel!
    @IBOutlet weak var walkingSteadinessGraph: UIView!
    @IBOutlet weak var GaitSegmentControl: UISegmentedControl!
    @IBOutlet weak var GaitCardView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

    private let chartView = WalkingSteadinessChartView()
    private var aggregatedPoints: [(date: Date, value: Double)] = []
    private var currentRange: SteadinessRange = .day
    private var pendingChartData: [(date: Date, value: Double)]? = nil

    enum SteadinessRange { case day, week, month, sixMonth, year }


override func viewDidLoad() {
        super.viewDidLoad()
        GaitCardView.applyCardStyle()
        title = "Walking Steadiness"
        navigationItem.largeTitleDisplayMode = .never
        steadinessFreq.text  = "Loading..."
        steadinessRange.text = ""
        setupChart()
        walkingSteadinessGraph.backgroundColor = .clear

        
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()

        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
        navigationController?.navigationBar.compactAppearance = standardAppearance
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let data = pendingChartData {
            pendingChartData = nil
            chartView.configure(with: data)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authorizeAndFetch()
    }



    private func setupChart() {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .clear
        chartView.isOpaque = false
        walkingSteadinessGraph.addSubview(chartView)
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: walkingSteadinessGraph.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: walkingSteadinessGraph.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: walkingSteadinessGraph.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: walkingSteadinessGraph.bottomAnchor),
        ])
    }


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
        steadinessRange.text = ""
        configureChart(with: [])
    }


    private func fetchData(for range: SteadinessRange) {
        let cal = Calendar.current
        let now = Date()

        steadinessFreq.text  = "Loading..."
        steadinessRange.text = ""
        let start: Date = {
            switch range {
            case .day:      return cal.date(byAdding: .weekOfYear, value: -1, to: now)!
            case .week:     return cal.date(byAdding: .day,        value: -7, to: now)!
            case .month:    return cal.date(byAdding: .month,      value: -1, to: now)!
            case .sixMonth: return cal.date(byAdding: .month,      value: -6, to: now)!
            case .year:     return cal.date(byAdding: .year,       value: -1, to: now)!
            }
        }()

        updateDateLabel(range: range, start: start, now: now)

        HealthKitManager.shared.fetchWalkingSteadinessSamples(from: start, to: now) { [weak self] rawSamples in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if !rawSamples.isEmpty {
                    let points = rawSamples
                        .sorted { $0.0 < $1.0 }
                        .map { (date: $0.0, value: min(max($0.1 * 100.0, 0), 100)) }
                    self.finalize(points: points)
                } else {
                    self.fetchComputedFallback(from: start, to: now)
                }
            }
        }
    }

    private func fetchComputedFallback(from start: Date, to end: Date) {
        HealthKitManager.shared.fetchComputedSteadinessSamples(from: start, to: end) { [weak self] points in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if !points.isEmpty {
                    self.finalize(points: points)
                } else {
                    self.steadinessFreq.text  = "No Data"
                    self.steadinessRange.text = ""
                    self.configureChart(with: [])
                }
            }
        }
    }


    private func finalize(points: [(date: Date, value: Double)]) {
        aggregatedPoints = points
        configureChart(with: points)

        guard !points.isEmpty else {
            steadinessFreq.text  = "No Data"
            steadinessRange.text = ""
            return
        }

        let avg = points.map { $0.value }.reduce(0, +) / Double(points.count)

        UIView.transition(with: steadinessFreq, duration: 0.3, options: .transitionCrossDissolve) {
            self.steadinessFreq.text      = String(format: "%.0f / 100", avg)
            self.steadinessFreq.textColor = .black
        }

        let (label, _) = classificationFor(avg)
        UIView.transition(with: steadinessRange, duration: 0.3, options: .transitionCrossDissolve) {
            self.steadinessRange.text      = label
            self.steadinessRange.textColor = .black
        }
    }


    private func configureChart(with points: [(date: Date, value: Double)]) {
        if chartView.bounds.width > 0 {
            chartView.configure(with: points)
        } else {
            pendingChartData = points
        }
    }

    private func classificationFor(_ v: Double) -> (String, UIColor) {
        if v >= 80 { return ("Good",              .systemGreen)  }
        if v >= 60 { return ("Moderate",          .systemOrange) }
        return             ("Low", .systemRed)
    }

    private func updateDateLabel(range: SteadinessRange, start: Date, now: Date) {
        let f = DateFormatter()
        switch range {
        case .day:
            f.dateFormat = "d MMM yyyy"
            dateLabel.text = f.string(from: now)
        case .week:
            f.dateFormat = "d MMM"
            dateLabel.text = "\(f.string(from: start)) - \(f.string(from: now))"
        case .month:
            f.dateFormat = "MMMM yyyy"
            dateLabel.text = f.string(from: now)
        case .sixMonth:
            f.dateFormat = "MMM yyyy"
            dateLabel.text = "\(f.string(from: start)) - \(f.string(from: now))"
        case .year:
            f.dateFormat = "yyyy"
            dateLabel.text = f.string(from: now)
        }
    }
}
