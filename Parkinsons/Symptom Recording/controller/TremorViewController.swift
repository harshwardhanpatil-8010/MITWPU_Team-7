import UIKit

struct AggregatedTremorPoint {
    let date: Date
    let avgHz: Double
}

class TremorViewController: UIViewController {

    var selectedDate: Date = Date()
    private var todayAggregatedPoints: [AggregatedTremorPoint] = []
    private var pendingGraphUpdate = false

    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var tremorFreq: UILabel!
    @IBOutlet weak var TremorGraphView: UIView!
    @IBOutlet weak var TremorSegmentControl: UISegmentedControl!
    @IBOutlet weak var TremorCardView: UIView!

    private var currentRange: TremorRange = .day
    override func viewDidLoad() {
        super.viewDidLoad()
        TremorCardView.applyCardStyle()
        setupNavigationBar()
        tremorFreq.text      = "Measuring…"
        tremorFreq.textColor = .secondaryLabel
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTremorUI(for: currentRange)
        startRecording()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if pendingGraphUpdate {
            pendingGraphUpdate = false
            updateTremorUI(for: currentRange)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TremorMotionManager.shared.cancelRecording()
    }
    private func startRecording() {
        TremorMotionManager.shared.recordTremorFrequency(duration: 5.0) { [weak self] result in
            guard let self = self else { return }

            TremorDataStore.shared.save(result: result)

            switch result {
            case .steady:
                self.tremorFreq.text      = "Steady"
                self.tremorFreq.textColor = .black
            case .tremor(let hz):
                self.tremorFreq.text      = String(format: "%.1f Hz", hz)
                self.tremorFreq.textColor = .black
            }

            self.updateTremorUI(for: self.currentRange)
        }
    }

    private func setupNavigationBar() {
        title = "Tremors"
        navigationItem.largeTitleDisplayMode = .never

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: currentRange = .day
        case 1: currentRange = .week
        case 2: currentRange = .month
        case 3: currentRange = .sixMonth
        case 4: currentRange = .year
        default: return
        }
        updateTremorUI(for: currentRange)
    }

    private func aggregateSamples(_ samples: [TremorSample], for range: TremorRange) -> [AggregatedTremorPoint] {
        let calendar = Calendar.current
        switch range {
        case .day:
            return samples.map { AggregatedTremorPoint(date: $0.date, avgHz: $0.frequencyHz) }
        case .week:
            return Dictionary(grouping: samples) { calendar.startOfDay(for: $0.date) }
                .map { AggregatedTremorPoint(date: $0.key, avgHz: $0.value.map { $0.frequencyHz }.average()) }
                .sorted { $0.date < $1.date }
        case .month:
            return Dictionary(grouping: samples) { calendar.dateInterval(of: .weekOfYear, for: $0.date)!.start }
                .map { AggregatedTremorPoint(date: $0.key, avgHz: $0.value.map { $0.frequencyHz }.average()) }
                .sorted { $0.date < $1.date }
        case .sixMonth, .year:
            return Dictionary(grouping: samples) { calendar.date(from: calendar.dateComponents([.year, .month], from: $0.date))! }
                .map { AggregatedTremorPoint(date: $0.key, avgHz: $0.value.map { $0.frequencyHz }.average()) }
                .sorted { $0.date < $1.date }
        }
    }

    private func updateTremorUI(for range: TremorRange) {
        let rawSamples = TremorDataStore.shared.fetchSamples(for: range, referenceDate: selectedDate)
        let aggregated = aggregateSamples(rawSamples, for: range)
        if range == .day { todayAggregatedPoints = aggregated }
        updateAverageLabel(aggregatedPoints: aggregated)
        updateGraph(using: aggregated, range: range)
        updateDateLabel(for: range)
    }

    private func updateAverageLabel(aggregatedPoints: [AggregatedTremorPoint]) {
        guard !aggregatedPoints.isEmpty else {
            tremorFreq.text = "Steady"
            tremorFreq.textColor = .black
            return
        }
        let avg = aggregatedPoints.map { $0.avgHz }.average()
        if avg < 0.1 {
            tremorFreq.text = "Steady"
            tremorFreq.textColor = .black
        } else {
            tremorFreq.text = String(format: "%.1f Hz", avg)
            tremorFreq.textColor = .black
        }
    }

    private func colorForHz(_ hz: Double) -> UIColor {
        if hz < 4.0 { return .systemYellow }
        if hz < 6.0 { return .systemOrange }
        return .systemRed
    }

    private func updateDateLabel(for range: TremorRange) {
        let formatter = DateFormatter()
        let now = Date()
        let calendar = Calendar.current
        switch range {
        case .day:
            formatter.dateFormat = "d MMM yyyy"; DateLabel.text = formatter.string(from: now)
        case .week:
            let start = calendar.date(byAdding: .day, value: -6, to: now)!
            formatter.dateFormat = "d MMM"
            DateLabel.text = "\(formatter.string(from: start)) – \(formatter.string(from: now))"
        case .month:
            formatter.dateFormat = "MMMM yyyy"; DateLabel.text = formatter.string(from: now)
        case .sixMonth:
            let start = calendar.date(byAdding: .month, value: -5, to: now)!
            formatter.dateFormat = "MMM yyyy"
            DateLabel.text = "\(formatter.string(from: start)) – \(formatter.string(from: now))"
        case .year:
            formatter.dateFormat = "yyyy"; DateLabel.text = formatter.string(from: now)
        }
    }

    private func xAxisLabels(for points: [AggregatedTremorPoint], range: TremorRange) -> [(index: Int, label: String)] {
        let calendar = Calendar.current
        var labels: [(Int, String)] = []
        switch range {
        case .day:
            let formatter = DateFormatter(); formatter.dateFormat = "HH:mm"
            let labelCount = min(5, points.count)
            guard labelCount > 0 else { return [] }
            for i in 0..<labelCount {
                let index = i * (points.count - 1) / max(labelCount - 1, 1)
                labels.append((index, formatter.string(from: points[index].date)))
            }
        case .week:
            let formatter = DateFormatter(); formatter.dateFormat = "EEE"
            let uniqueDays = Dictionary(grouping: points.indices) { calendar.startOfDay(for: points[$0].date) }
            for (_, indices) in uniqueDays.sorted(by: { $0.key < $1.key }) {
                if let first = indices.first { labels.append((first, formatter.string(from: points[first].date))) }
            }
        case .month:
            let formatter = DateFormatter(); formatter.dateFormat = "d"
            for (i, sample) in points.enumerated() {
                let day = calendar.component(.day, from: sample.date)
                if [7, 14, 21, 28].contains(day) { labels.append((i, formatter.string(from: sample.date))) }
            }
        case .sixMonth, .year:
            let formatter = DateFormatter(); formatter.dateFormat = "MMM"
            let uniqueMonths = Dictionary(grouping: points.indices) { calendar.component(.month, from: points[$0].date) }
            for (_, indices) in uniqueMonths.sorted(by: { $0.key < $1.key }) {
                if let first = indices.first {
                    let label = formatter.string(from: points[first].date)
                    labels.append((first, range == .year ? String(label.prefix(1)) : label))
                }
            }
        }
        return labels
    }

    private func updateGraph(using points: [AggregatedTremorPoint], range: TremorRange) {
        TremorGraphView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let width  = TremorGraphView.bounds.width
        let height = TremorGraphView.bounds.height

        guard width > 0, height > 0 else {
            pendingGraphUpdate = true
            return
        }
        let pLeft: CGFloat = 44
        let pBottom: CGFloat = 28
        let pTop: CGFloat = 22
        let pRight: CGFloat = 12
        let usableW = width - pLeft - pRight
        let usableH = height - pBottom - pTop
        let count = points.count
        let safeCount = max(count - 1, 1)
        let minHz: Double = 0
        let maxHz = max(points.map { $0.avgHz }.max() ?? 6, 6)

        let hzLbl = CATextLayer()
        hzLbl.string = "Hz"; hzLbl.fontSize = 8
        hzLbl.foregroundColor = UIColor.tertiaryLabel.cgColor
        hzLbl.frame = CGRect(x: 0, y: 4, width: pLeft - 6, height: 12)
        hzLbl.alignmentMode = .right; hzLbl.contentsScale = UIScreen.main.scale
        TremorGraphView.layer.addSublayer(hzLbl)

        for i in 0...4 {
            let value = minHz + (Double(i) / 4.0) * (maxHz - minHz)
            let y = height - pBottom - CGFloat(i) / 4.0 * usableH
            let gridPath = UIBezierPath()
            gridPath.move(to: CGPoint(x: pLeft, y: y))
            gridPath.addLine(to: CGPoint(x: width - pRight, y: y))
            let gl = CAShapeLayer(); gl.path = gridPath.cgPath
            gl.strokeColor = UIColor.systemGray5.cgColor; gl.lineWidth = 1
            TremorGraphView.layer.addSublayer(gl)

            let lbl = CATextLayer()
            lbl.string = String(format: "%.0f", value); lbl.fontSize = 9
            lbl.foregroundColor = UIColor.secondaryLabel.cgColor
            lbl.frame = CGRect(x: 0, y: y - 6, width: pLeft - 8, height: 12)
            lbl.alignmentMode = .right; lbl.contentsScale = UIScreen.main.scale
            TremorGraphView.layer.addSublayer(lbl)
        }

        for item in xAxisLabels(for: points, range: range) {
            let x = pLeft + CGFloat(item.index) / CGFloat(safeCount) * usableW
            let lbl = CATextLayer()
            lbl.string = item.label; lbl.fontSize = 9
            lbl.foregroundColor = UIColor.secondaryLabel.cgColor
            lbl.frame = CGRect(x: x - 20, y: height - pBottom + 6, width: 40, height: 14)
            lbl.alignmentMode = .center; lbl.contentsScale = UIScreen.main.scale
            TremorGraphView.layer.addSublayer(lbl)
        }

        guard count > 0 else { return }

        let refY = height - pBottom - CGFloat((3.0 - minHz) / (maxHz - minHz)) * usableH
        let refPath = UIBezierPath()
        refPath.move(to: CGPoint(x: pLeft, y: refY))
        refPath.addLine(to: CGPoint(x: width - pRight, y: refY))
        let refLayer = CAShapeLayer(); refLayer.path = refPath.cgPath
        refLayer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.4).cgColor
        refLayer.lineWidth = 1; refLayer.lineDashPattern = [5, 4]
        TremorGraphView.layer.addSublayer(refLayer)

        var coords: [CGPoint] = []
        for (i, point) in points.enumerated() {
            let x = pLeft + CGFloat(i) / CGFloat(safeCount) * usableW
            let y = height - pBottom - CGFloat((point.avgHz - minHz) / (maxHz - minHz)) * usableH
            coords.append(CGPoint(x: x, y: y))
        }

        let fillPath = UIBezierPath()
        fillPath.move(to: CGPoint(x: coords[0].x, y: height - pBottom))
        fillPath.addLine(to: coords[0])
        for i in 1..<coords.count {
            let p   = coords[i - 1]
            let cur = coords[i]
            let cp1 = CGPoint(x: p.x + (cur.x - p.x) * 0.4, y: p.y)
            let cp2 = CGPoint(x: cur.x - (cur.x - p.x) * 0.4, y: cur.y)
            fillPath.addCurve(to: cur, controlPoint1: cp1, controlPoint2: cp2)
        }
        fillPath.addLine(to: CGPoint(x: coords.last!.x, y: height - pBottom))
        fillPath.close()

        let gradLayer = CAGradientLayer()
        gradLayer.frame = TremorGraphView.bounds
        gradLayer.colors = [UIColor.systemOrange.withAlphaComponent(0.20).cgColor, UIColor.systemOrange.withAlphaComponent(0.0).cgColor]
        gradLayer.startPoint = CGPoint(x: 0.5, y: 0); gradLayer.endPoint = CGPoint(x: 0.5, y: 1)
        let fillMask = CAShapeLayer(); fillMask.path = fillPath.cgPath
        gradLayer.mask = fillMask
        TremorGraphView.layer.addSublayer(gradLayer)

        let linePath = UIBezierPath()
        linePath.move(to: coords[0])
        for i in 1..<coords.count {
            let p   = coords[i - 1]
            let cur = coords[i]
            let cp1 = CGPoint(x: p.x + (cur.x - p.x) * 0.4, y: p.y)
            let cp2 = CGPoint(x: cur.x - (cur.x - p.x) * 0.4, y: cur.y)
            linePath.addCurve(to: cur, controlPoint1: cp1, controlPoint2: cp2)
        }
        let lineLayer = CAShapeLayer(); lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = UIColor.systemOrange.cgColor; lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 2; lineLayer.lineJoin = .round; lineLayer.lineCap = .round
        TremorGraphView.layer.addSublayer(lineLayer)

        let dotRadius: CGFloat = count > 14 ? 3 : 5
        for pt in coords {
            let ringPath = UIBezierPath(arcCenter: pt, radius: dotRadius + 2,
                                        startAngle: 0, endAngle: .pi * 2, clockwise: true)
            let ringLayer = CAShapeLayer()
            ringLayer.path      = ringPath.cgPath
            ringLayer.fillColor = UIColor.white.cgColor
            TremorGraphView.layer.addSublayer(ringLayer)

            let dotPath = UIBezierPath(arcCenter: pt, radius: dotRadius,
                                       startAngle: 0, endAngle: .pi * 2, clockwise: true)
            let dotLayer = CAShapeLayer()
            dotLayer.path      = dotPath.cgPath
            dotLayer.fillColor = UIColor.systemOrange.cgColor
            TremorGraphView.layer.addSublayer(dotLayer)
        }
    }
}

extension Array where Element == Double {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
