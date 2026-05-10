// MedicationAlarmViewController.swift
// Parkinsons
//
// Full-screen alarm presented when a medication notification fires
// while the app is in the foreground, OR when the user taps a notification
// that opens the app.
//
// Layout is done entirely in code via Auto Layout so you only need to add
// a blank UIViewController scene in the storyboard with the identifier
// "MedicationAlarmVC", set its custom class to MedicationAlarmViewController,
// and connect nothing — all outlets are created programmatically here.

import UIKit
import CoreData
import AVFoundation

// MARK: - Notification payload model (decoded from userInfo)

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
        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        
        medIconImageView.contentMode = .scaleAspectFit
        let icon = payload.iconName.isEmpty ? "tablet1" : payload.iconName
        if let img = UIImage(named: icon) {
            medIconImageView.image = img // Full color original image
        } else {
            medIconImageView.image = UIImage(systemName: "pills.fill")
            medIconImageView.tintColor = .systemBlue
        }
        
        titleLabel.text = payload.medName
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        var unitStr = payload.medUnit
        if let dotIndex = unitStr.firstIndex(of: "•") {
            unitStr = String(unitStr[..<dotIndex]).trimmingCharacters(in: .whitespaces)
        }
        
        let strengthStr = payload.medStrength > 0 ? "\(payload.medStrength)\(unitStr)" : unitStr
        subtitleLabel.text = strengthStr
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        
        takenButton.setTitle("Taken", for: .normal)
        takenButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        takenButton.configuration?.baseForegroundColor = .systemBlue
        takenButton.configuration?.baseBackgroundColor = .systemBlue
        takenButton.configuration?.cornerStyle = .capsule
        takenButton.configuration?.imagePadding = 8
        takenButton.addTarget(self, action: #selector(takenTapped), for: .touchUpInside)
        
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        skipButton.configuration?.baseForegroundColor = .systemGray
        skipButton.configuration?.baseBackgroundColor = .systemGray
        skipButton.configuration?.cornerStyle = .capsule
        skipButton.configuration?.imagePadding = 8
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [takenButton, skipButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        let mainStack = UIStackView(arrangedSubviews: [medIconImageView, titleLabel, subtitleLabel, buttonStack])
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.spacing = 8
        mainStack.setCustomSpacing(16, after: subtitleLabel)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            medIconImageView.widthAnchor.constraint(equalToConstant: 80),
            medIconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            buttonStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor),
            takenButton.heightAnchor.constraint(equalToConstant: 50),
            skipButton.heightAnchor.constraint(equalToConstant: 50),
            
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
    
    @objc private func takenTapped() { onAction?(payload, .taken) }
    @objc private func skipTapped() { onAction?(payload, .skipped) }
}

// MARK: - View Controller

class MedicationAlarmViewController: UIViewController {
    
    var payloads: [MedicationAlarmPayload] = []
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let headerLabel = UILabel()
    private var activeCards = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateCards()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        headerLabel.text = "Due Medications"
        headerLabel.font = .systemFont(ofSize: 32, weight: .bold)
        headerLabel.textColor = .label
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            scrollView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
    
    private func logDose(payload: MedicationAlarmPayload, status: DoseStatus, cardView: MedicationCardView) {
        // Disable buttons immediately
        cardView.isUserInteractionEnabled = false
        
        // Notification management
        if status == .skipped {
            MedicationNotificationManager.shared.cancelOnTimeNotification(forDoseID: payload.doseID)
            MedicationNotificationManager.shared.scheduleSkipFollowUp(payload: payload)
        } else {
            MedicationNotificationManager.shared.cancelNotifications(forDoseID: payload.doseID)
        }

        // Core Data
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
                name: .medicationDoseLogged,
                object: nil,
                userInfo: ["doseID": payload.doseID]
            )
        }

        // Animate card out
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
            // Safety: Don't present if the app's UI isn't ready yet
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

extension Notification.Name {
    static let medicationDoseLogged = Notification.Name("medicationDoseLogged")
}
