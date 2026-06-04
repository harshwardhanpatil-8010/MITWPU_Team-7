import UIKit
import PDFKit

final class SymptomReportGenerator {
    
    static let shared = SymptomReportGenerator()
    
    private init() {}
    
    func generateReport(for range: String, referenceDate: Date, completion: @escaping (URL?) -> Void) {
        let (startDate, endDate) = calculateDateRange(for: range, referenceDate: referenceDate)
        
        let dispatchGroup = DispatchGroup()
        
        var tremorSamples: [TremorSample] = []
        var gaitSamples: [(Date, Double)] = []
        var symptomLogs: [SymptomLogEntry] = []
        
        dispatchGroup.enter()
        let tremorRange: TremorRange = (range == "Weekly") ? .week : .month
        tremorSamples = TremorDataStore.shared.fetchSamples(for: tremorRange, referenceDate: referenceDate)
        dispatchGroup.leave()
        
        dispatchGroup.enter()
        HealthKitManager.shared.fetchWalkingSteadinessSamples(from: startDate, to: endDate) { samples in
            gaitSamples = samples
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        symptomLogs = SymptomLogManager.shared.fetchLogs(from: startDate, to: endDate)
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            let pdfData = self.createPDF(range: range, startDate: startDate, endDate: endDate, tremor: tremorSamples, gait: gaitSamples, logs: symptomLogs)
            
            let fileName = "SymptomReport_\(range)_\(self.formatDateForFileName(startDate)).pdf"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try pdfData.write(to: tempURL)
                completion(tempURL)
            } catch {
                print("PDF saving error:", error)
                completion(nil)
            }
        }
    }
    
    private func calculateDateRange(for range: String, referenceDate: Date) -> (Date, Date) {
        let cal = Calendar.current
        if range == "Weekly" {
            let start = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: referenceDate))!
            let end = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: referenceDate))!
            return (start, end)
        } else {
            let start = cal.date(from: cal.dateComponents([.year, .month], from: referenceDate))!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
        }
    }
    
    private func formatDateForFileName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func createPDF(range: String, startDate: Date, endDate: Date, tremor: [TremorSample], gait: [(Date, Double)], logs: [SymptomLogEntry]) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Parkinsons Monitoring App",
            kCGPDFContextAuthor: "Patient Report",
            kCGPDFContextTitle: "\(range) Health Summary"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 50
        let contentWidth = pageWidth - (margin * 2)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            var currentY: CGFloat = margin
            
            let appName = "PARKINSON'S MONITOR"
            let appNameAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .black),
                .foregroundColor: UIColor.systemBlue,
                .kern: 1.5
            ]
            appName.draw(at: CGPoint(x: margin, y: currentY), withAttributes: appNameAttr)
            
            let reportTitle = "\(range) Progress Report"
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            currentY += 18
            reportTitle.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttr)
            
            currentY += 38
            let dateRangeStr = " PERIOD: \(formatDate(startDate)) – \(formatDate(Calendar.current.date(byAdding: .day, value: -1, to: endDate)!)) "
            let dateAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let dateSize = dateRangeStr.size(withAttributes: dateAttr)
            let badgeRect = CGRect(x: margin, y: currentY, width: dateSize.width + 12, height: dateSize.height + 6)
            let badgePath = UIBezierPath(roundedRect: badgeRect, cornerRadius: 4)
            UIColor.systemGray.setFill()
            badgePath.fill()
            dateRangeStr.draw(at: CGPoint(x: margin + 6, y: currentY + 3), withAttributes: dateAttr)
            
            currentY += badgeRect.height + 30
            
            drawSectionHeader("NEUROMOTOR TRENDS", y: &currentY, width: contentWidth, margin: margin)
            
            drawModernSectionTitle("Tremor Frequency", subtitle: "Average tremors measured in Hertz (Hz)", y: &currentY, margin: margin)
            let tremorPoints = tremor.map { (date: $0.date, value: $0.frequencyHz) }
            drawEnhancedGraph(points: tremorPoints, rect: CGRect(x: margin, y: currentY, width: contentWidth, height: 120), color: .systemOrange, maxValue: 12, unit: "Hz")
            currentY += 160
            
            drawModernSectionTitle("Walking Steadiness", subtitle: "Stability percentage recorded by HealthKit", y: &currentY, margin: margin)
            let gaitPoints = gait.map { (date: $0.0, value: $0.1 * 100) }
            drawEnhancedGraph(points: gaitPoints, rect: CGRect(x: margin, y: currentY, width: contentWidth, height: 120), color: .systemBlue, maxValue: 100, unit: "%")
            currentY += 180
            
            if currentY > pageHeight - 150 { context.beginPage(); currentY = margin }
            drawSectionHeader("DAILY SYMPTOM TRACKING", y: &currentY, width: contentWidth, margin: margin)
            
            let symptomTypes = SymptomType.allCases.filter { $0 != .tremors && $0 != .gaitDisturbance }
            
            for type in symptomTypes {
                if currentY > pageHeight - 180 {
                    context.beginPage()
                    currentY = margin
                }
                
                drawModernSectionTitle(type.displayName, subtitle: "Recorded severity levels", y: &currentY, margin: margin)
                
                let points = logs.compactMap { entry -> (Date, Double)? in
                    guard let rating = entry.ratings.first(where: { $0.name == type.displayName }),
                          let intensity = rating.selectedIntensity else { return nil }
                    
                    let val: Double
                    switch intensity {
                    case .severe: val = 3
                    case .moderate: val = 2
                    case .mild: val = 1
                    case .notPresent: val = 0
                    }
                    return (entry.date, val)
                }
                
                drawEnhancedSeverityGraph(points: points, rect: CGRect(x: margin, y: currentY, width: contentWidth, height: 80), color: .systemPurple)
                currentY += 130
            }
            
            let footer = "Generated on \(formatDate(Date())) • Parkinson's Monitoring System"
            let footerAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9), .foregroundColor: UIColor.secondaryLabel]
            let footerSize = footer.size(withAttributes: footerAttr)
            footer.draw(at: CGPoint(x: (pageWidth - footerSize.width) / 2, y: pageHeight - 30), withAttributes: footerAttr)
        }
        
        return data
    }
    
    private func drawSectionHeader(_ title: String, y: inout CGFloat, width: CGFloat, margin: CGFloat) {
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .black),
            .foregroundColor: UIColor.secondaryLabel,
            .kern: 1.2
        ]
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: attr)
        y += 15
        let line = UIBezierPath()
        line.move(to: CGPoint(x: margin, y: y))
        line.addLine(to: CGPoint(x: margin + width, y: y))
        UIColor.systemGray5.setStroke()
        line.lineWidth = 1
        line.stroke()
        y += 20
    }
    
    private func drawModernSectionTitle(_ title: String, subtitle: String, y: inout CGFloat, margin: CGFloat) {
        let titleAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .bold)]
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttr)
        y += 18
        let subAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9), .foregroundColor: UIColor.secondaryLabel]
        subtitle.draw(at: CGPoint(x: margin, y: y), withAttributes: subAttr)
        y += 12
    }
    
    private func drawEnhancedGraph(points: [(date: Date, value: Double)], rect: CGRect, color: UIColor, maxValue: Double, unit: String) {
        let context = UIGraphicsGetCurrentContext()
        
        let bgPath = UIBezierPath(roundedRect: rect.insetBy(dx: -10, dy: -10), cornerRadius: 12)
        UIColor.systemGray6.withAlphaComponent(0.5).setFill()
        bgPath.fill()
        
        context?.setStrokeColor(UIColor.systemGray4.cgColor)
        context?.setLineWidth(0.25)
        for i in 0...4 {
            let y = rect.minY + CGFloat(i) * (rect.height / 4)
            context?.move(to: CGPoint(x: rect.minX, y: y))
            context?.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        context?.strokePath()
        
        let labelAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 7, weight: .medium), .foregroundColor: UIColor.secondaryLabel]
        "\(Int(maxValue))\(unit)".draw(at: CGPoint(x: rect.minX - 35, y: rect.minY - 4), withAttributes: labelAttr)
        "0\(unit)".draw(at: CGPoint(x: rect.minX - 35, y: rect.maxY - 4), withAttributes: labelAttr)
        
        guard !points.isEmpty else {
            let noData = "NO DATA RECORDED"
            let attr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9, weight: .bold), .foregroundColor: UIColor.systemGray3]
            let size = noData.size(withAttributes: attr)
            noData.draw(at: CGPoint(x: rect.midX - size.width/2, y: rect.midY - size.height/2), withAttributes: attr)
            return
        }
        
        let sortedPoints = points.sorted { $0.date < $1.date }
        let startDate = sortedPoints.first!.date
        let endDate = sortedPoints.last!.date
        let timeRange = max(endDate.timeIntervalSince(startDate), 86400 * 6) // Minimum 1 week range visually
        
        let path = UIBezierPath()
        let fillPath = UIBezierPath()
        
        var firstPoint: CGPoint?
        var lastPoint: CGPoint?
        
        for (i, pt) in sortedPoints.enumerated() {
            let x = rect.minX + CGFloat(pt.date.timeIntervalSince(startDate) / timeRange) * rect.width
            let y = rect.maxY - CGFloat(min(pt.value, maxValue) / maxValue) * rect.height
            
            let currentPoint = CGPoint(x: x, y: y)
            if i == 0 {
                path.move(to: currentPoint)
                fillPath.move(to: CGPoint(x: x, y: rect.maxY))
                fillPath.addLine(to: currentPoint)
                firstPoint = currentPoint
            } else {
                path.addLine(to: currentPoint)
                fillPath.addLine(to: currentPoint)
            }
            lastPoint = currentPoint
            
            let dot = UIBezierPath(ovalIn: CGRect(x: x - 2.5, y: y - 2.5, width: 5, height: 5))
            UIColor.white.setFill()
            dot.fill()
            color.setStroke()
            dot.lineWidth = 1.5
            dot.stroke()
        }
        
        if let last = lastPoint {
            fillPath.addLine(to: CGPoint(x: last.x, y: rect.maxY))
            fillPath.close()
            color.withAlphaComponent(0.1).setFill()
            fillPath.fill()
        }
        
        color.setStroke()
        path.lineWidth = 2.5
        path.lineJoinStyle = .round
        path.stroke()
    }
    
    private func drawEnhancedSeverityGraph(points: [(date: Date, value: Double)], rect: CGRect, color: UIColor) {
        let context = UIGraphicsGetCurrentContext()
        
        let bgPath = UIBezierPath(roundedRect: rect.insetBy(dx: -10, dy: -10), cornerRadius: 8)
        UIColor.systemGray6.withAlphaComponent(0.3).setFill()
        bgPath.fill()
        
        let labels = ["Severe", "Moderate", "Mild", "Not Present"]
        for i in 0...3 {
            let y = rect.minY + CGFloat(i) * (rect.height / 3)
            context?.setStrokeColor(UIColor.systemGray5.cgColor)
            context?.setLineWidth(0.5)
            context?.move(to: CGPoint(x: rect.minX, y: y))
            context?.addLine(to: CGPoint(x: rect.maxX, y: y))
            context?.strokePath()
            
            let labelAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 7), .foregroundColor: UIColor.secondaryLabel]
            labels[i].draw(at: CGPoint(x: rect.minX - 55, y: y - 4), withAttributes: labelAttr)
        }
        
        guard !points.isEmpty else { return }
        
        let sortedPoints = points.sorted { $0.date < $1.date }
        let startDate = sortedPoints.first!.date
        let endDate = sortedPoints.last!.date
        let timeRange = max(endDate.timeIntervalSince(startDate), 86400 * 6)
        
        let path = UIBezierPath()
        for (i, pt) in sortedPoints.enumerated() {
            let x = rect.minX + CGFloat(pt.date.timeIntervalSince(startDate) / timeRange) * rect.width
            let y = rect.maxY - CGFloat(pt.value / 3.0) * rect.height
            
            let currentPoint = CGPoint(x: x, y: y)
            if i == 0 {
                path.move(to: currentPoint)
            } else {
                path.addLine(to: currentPoint)
            }
            
            let dot = UIBezierPath(ovalIn: CGRect(x: x - 2, y: y - 2, width: 4, height: 4))
            color.setFill()
            dot.fill()
        }
        
        color.withAlphaComponent(0.6).setStroke()
        path.lineWidth = 1.5
        path.stroke()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
