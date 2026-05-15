// MedicationAlarmViewController.swift
// Parkinsons
//

import UIKit
import CoreData
import AVFoundation


struct MedicationAlarmPayload {
    let doseID:        UUID
    let medID:         UUID
    let medName:       String
    let medForm:       String
    let medStrength:   Int
    let medUnit:       String
    let iconName:      String
    let scheduledTime: Date

    init?(userInfo: [AnyHashable: Any]) {
        guard
            let doseStr = userInfo[MedNotifKey.doseID]  as? String,
            let medStr  = userInfo[MedNotifKey.medID]   as? String,
            let doseID  = UUID(uuidString: doseStr),
            let medID   = UUID(uuidString: medStr)
        else { return nil }

        let iso = ISO8601DateFormatter()
        let timeStr = userInfo[MedNotifKey.scheduledTime] as? String ?? ""

        self.doseID        = doseID
        self.medID         = medID
        self.medName       = userInfo[MedNotifKey.medName]     as? String ?? "Medication"
        self.medForm       = userInfo[MedNotifKey.medForm]     as? String ?? ""
        self.medStrength   = userInfo[MedNotifKey.medStrength] as? Int    ?? 0
        self.medUnit       = userInfo[MedNotifKey.medUnit]     as? String ?? ""
        self.iconName      = userInfo[MedNotifKey.iconName]    as? String ?? "tablet1"
        self.scheduledTime = iso.date(from: timeStr) ?? Date()
    }
    
    static func parsePayloads(from userInfo: [AnyHashable: Any]) -> [MedicationAlarmPayload] {
        if let arr = userInfo["payloads"] as? [[AnyHashable: Any]] {
            return arr.compactMap { MedicationAlarmPayload(userInfo: $0) }
        }
        if let single = MedicationAlarmPayload(userInfo: userInfo) {
            return [single]
        }
        return []
    }
}

// MARK: - Card View

final class MedicationCardView: UIView {

    let payload: MedicationAlarmPayload
    var onAction: ((MedicationAlarmPayload, DoseStatus) -> Void)?

    private let medIconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let takenButton = UIButton(configuration: .tinted())
    private let skipButton = UIButton(configuration: .tinted())

    init(payload: MedicationAlarmPayload) {
        self.payload = payload
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .white
        applyCardStyle()

        // MARK: - Icon
        medIconImageView.contentMode = .scaleAspectFit
        medIconImageView.translatesAutoresizingMaskIntoConstraints = false

        let icon = payload.iconName.isEmpty ? "tablet1" : payload.iconName
        medIconImageView.image = UIImage(named: icon) ?? UIImage(systemName: "pills.fill")

        // MARK: - Labels
        titleLabel.text = payload.medName
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        var unitStr = payload.medUnit
        if let dotIndex = unitStr.firstIndex(of: "•") {
            unitStr = String(unitStr[..<dotIndex]).trimmingCharacters(in: .whitespaces)
        }

        let strengthStr = payload.medStrength > 0 ? "\(payload.medStrength)\(unitStr)" : unitStr
        subtitleLabel.text = strengthStr
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        // MARK: - Buttons
        takenButton.setTitle("Taken", for: .normal)
        takenButton.configuration?.baseForegroundColor = .systemBlue
        takenButton.configuration?.baseBackgroundColor = .systemBlue
        takenButton.configuration?.cornerStyle = .capsule
        takenButton.addTarget(self, action: #selector(takenTapped), for: .touchUpInside)

        skipButton.setTitle("Skip", for: .normal)
        skipButton.configuration?.baseForegroundColor = .systemGray
        skipButton.configuration?.baseBackgroundColor = .systemGray
        skipButton.configuration?.cornerStyle = .capsule
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [takenButton, skipButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually

        // MARK: - Top Row (icon + text)
        let topRow = UIStackView(arrangedSubviews: [medIconImageView, textStack])
        topRow.axis = .horizontal
        topRow.spacing = 12
        topRow.alignment = .center

        // MARK: - Main Stack
        let mainStack = UIStackView(arrangedSubviews: [topRow, buttonStack])
        mainStack.axis = .vertical
        mainStack.spacing = 10
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)

        NSLayoutConstraint.activate([
            medIconImageView.widthAnchor.constraint(equalToConstant: 40),
            medIconImageView.heightAnchor.constraint(equalToConstant: 40),

            takenButton.heightAnchor.constraint(equalToConstant: 36),
            skipButton.heightAnchor.constraint(equalToConstant: 36),

            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    @objc private func takenTapped() {
        onAction?(payload, .taken)
    }

    @objc private func skipTapped() {
        onAction?(payload, .skipped)
    }
}
// MARK: - View Controller

class MedicationAlarmViewController: UIViewController {
    
    var payloads: [MedicationAlarmPayload] = []
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let headerLabel = UILabel()
    private var activeCards = 0
    
    private let takenAllButton = UIButton(configuration: .tinted())
    private let skipAllButton = UIButton(configuration: .tinted())
    private let bottomStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateCards()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        headerLabel.text = "Due Medications"
        headerLabel.font = .systemFont(ofSize: 32, weight: .bold)
        headerLabel.textColor = .label
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        takenAllButton.setTitle("Taken All", for: .normal)
        takenAllButton.configuration?.baseForegroundColor = .systemBlue
        takenAllButton.configuration?.baseBackgroundColor = .systemBlue
        takenAllButton.configuration?.cornerStyle = .capsule
        takenAllButton.configuration?.imagePadding = 8
        takenAllButton.addTarget(self, action: #selector(takenAllTapped), for: .touchUpInside)
        
        skipAllButton.setTitle("Skipped All", for: .normal)
        skipAllButton.configuration?.baseForegroundColor = .systemGray
        skipAllButton.configuration?.baseBackgroundColor = .systemGray
        skipAllButton.configuration?.cornerStyle = .capsule
        skipAllButton.configuration?.imagePadding = 8
        skipAllButton.addTarget(self, action: #selector(skipAllTapped), for: .touchUpInside)
        
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 16
        bottomStackView.distribution = .fillEqually
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.addArrangedSubview(takenAllButton)
        bottomStackView.addArrangedSubview(skipAllButton)
        
        view.addSubview(headerLabel)
        view.addSubview(scrollView)
        view.addSubview(bottomStackView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            scrollView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor, constant: -16),
            
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            bottomStackView.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -40),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])
    }
    
    private func populateCards() {
        activeCards = payloads.count
        for payload in payloads {
            let card = MedicationCardView(payload: payload)
            card.onAction = { [weak self] p, status in
                self?.logDose(payload: p, status: status, cardView: card)
            }
            stackView.addArrangedSubview(card)
        }
    }
    
    @objc private func takenAllTapped() {
        processAll(status: .taken)
    }

    @objc private func skipAllTapped() {
        processAll(status: .skipped)
    }

    private func processAll(status: DoseStatus) {

        takenAllButton.isEnabled = false
        skipAllButton.isEnabled = false
        
        let cards = stackView.arrangedSubviews
            .compactMap { $0 as? MedicationCardView }
            .filter { !$0.isHidden && $0.isUserInteractionEnabled }
        
        for card in cards {

            card.onAction?(card.payload, status)
        }
    }
    
    private func logDose(payload: MedicationAlarmPayload, status: DoseStatus, cardView: MedicationCardView) {

        cardView.isUserInteractionEnabled = false
        

        if status == .skipped {
            MedicationNotificationManager.shared.cancelOnTimeNotification(forDoseID: payload.doseID)
            MedicationNotificationManager.shared.scheduleSkipFollowUp(payload: payload)
        } else {
            MedicationNotificationManager.shared.cancelNotifications(forDoseID: payload.doseID)
        }


        let context = PersistenceController.shared.viewContext
        let medRequest: NSFetchRequest<Medication> = Medication.fetchRequest()
        medRequest.predicate = NSPredicate(format: "id == %@", payload.medID as CVarArg)

        if let med = try? context.fetch(medRequest).first,
           let doseSet = med.doses as? Set<MedicationDose>,
           let coreDose = doseSet.first(where: { $0.id == payload.doseID }) {
            
            coreDose.doseStatus = status.rawValue

            let log = MedicationDoseLog(context: context)
            log.id = UUID()
            log.doseScheduledTime = payload.scheduledTime
            log.doseDay = Calendar.current.startOfDay(for: Date())
            log.doseLoggedAt = Date()
            log.doseLogStatus = status.rawValue
            log.dose = coreDose
            log.medication = med

            PersistenceController.shared.save(context)

            NotificationCenter.default.post(
                name: NSNotification.Name("MedicationLogged"),
                object: nil,
                userInfo: ["doseID": payload.doseID]
            )
        }


        UIView.animate(withDuration: 0.3, animations: {
            cardView.alpha = 0
            cardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { [weak self] _ in
            guard let self = self else { return }
            cardView.isHidden = true
            self.activeCards -= 1
            if self.activeCards <= 0 {
                self.dismiss(animated: true)
            }
        }
    }

    // MARK: - Presentation Helper

    static func present(payloads: [MedicationAlarmPayload]) {
        guard !payloads.isEmpty else { return }

        DispatchQueue.main.async {

            guard let top = topViewController() else { return }
            
            if let existing = top as? MedicationAlarmViewController {
                let existingIDs = Set(existing.payloads.map { $0.doseID })
                let filtered = payloads.filter { !existingIDs.contains($0.doseID) }
                if !filtered.isEmpty {
                    existing.payloads.append(contentsOf: filtered)
                }
                return
            }

            let alarmVC = MedicationAlarmViewController()
            alarmVC.payloads = payloads
            alarmVC.modalPresentationStyle = .overFullScreen
            alarmVC.modalTransitionStyle = .crossDissolve
            top.present(alarmVC, animated: true)
        }
    }

    private static func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}


