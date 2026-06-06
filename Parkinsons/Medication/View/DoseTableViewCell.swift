//
//  DoseTableViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

protocol DoseTableViewCellDelegate: AnyObject {
    func didTapDelete(cell: DoseTableViewCell)
    func didUpdateDose(cell: DoseTableViewCell, period: String, startTime: Date, endTime: Date)
}

class DoseTableViewCell: UITableViewCell {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var doseNumberLabel: UILabel!
    @IBOutlet weak var doseLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    weak var delegate: DoseTableViewCellDelegate?

    private var isCustomControlsSetup = false
    private var periodButton: UIButton!
    private var startTimePicker: UIDatePicker!
    private var endTimePicker: UIDatePicker!
    private var fromLabel: UILabel!
    private var toLabel: UILabel!

    private var currentPeriod: String = "Morning"
    private var currentStartTime: Date = Date()
    private var currentEndTime: Date = Date()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func deleteTapped(_ sender: UIButton) {
        delegate?.didTapDelete(cell: self)
    }

    @IBAction func timeChanged(_ sender: UIDatePicker) {
        // Obsolete for custom UI, but kept for storyboard compatibility
    }

    func configure(period: String, startTime: Date, endTime: Date, doseIndex: Int) {
        setupCustomControlsIfNeeded()

        self.doseNumberLabel.text = "\(doseIndex)"
        self.currentPeriod = period
        self.currentStartTime = startTime
        self.currentEndTime = endTime

        periodButton.setTitle(period, for: .normal)
        startTimePicker.date = startTime
        endTimePicker.date = endTime

        updatePeriodMenu()
    }

    private func setupCustomControlsIfNeeded() {
        guard !isCustomControlsSetup else { return }
        isCustomControlsSetup = true

        timePicker.isHidden = true
        doseLabel.isHidden = true
        doseNumberLabel.isHidden = true

        periodButton = UIButton(type: .system)
        periodButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        periodButton.showsMenuAsPrimaryAction = true

        startTimePicker = UIDatePicker()
        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .compact
        startTimePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)

        endTimePicker = UIDatePicker()
        endTimePicker.datePickerMode = .time
        endTimePicker.preferredDatePickerStyle = .compact
        endTimePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)

        fromLabel = UILabel()
        fromLabel.text = "from"
        fromLabel.textColor = .secondaryLabel
        fromLabel.font = .systemFont(ofSize: 12)

        toLabel = UILabel()
        toLabel.text = "to"
        toLabel.textColor = .secondaryLabel
        toLabel.font = .systemFont(ofSize: 12)

        if let stackView = timePicker.superview as? UIStackView {
            stackView.addArrangedSubview(periodButton)
            stackView.addArrangedSubview(fromLabel)
            stackView.addArrangedSubview(startTimePicker)
            stackView.addArrangedSubview(toLabel)
            stackView.addArrangedSubview(endTimePicker)
            stackView.spacing = 4
        }
    }

    private func updatePeriodMenu() {
        let periods = ["Morning", "Afternoon", "Evening", "Night", "Custom"]
        var actions: [UIAction] = []

        for p in periods {
            let action = UIAction(title: p, state: p == currentPeriod ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                self.currentPeriod = p
                self.periodButton.setTitle(p, for: .normal)

                let cal = Calendar.current
                let startH: Int
                let endH: Int
                let endM: Int
                var shouldUpdateTimes = true

                switch p {
                case "Morning": startH = 8; endH = 11; endM = 0
                case "Afternoon": startH = 12; endH = 15; endM = 0
                case "Evening": startH = 17; endH = 20; endM = 0
                case "Night": startH = 21; endH = 23; endM = 59
                case "Custom":
                    shouldUpdateTimes = false
                    startH = 12; endH = 13; endM = 0
                default: startH = 8; endH = 11; endM = 0
                }

                if shouldUpdateTimes {
                    self.currentStartTime = cal.date(bySettingHour: startH, minute: 0, second: 0, of: self.currentStartTime) ?? self.currentStartTime
                    self.currentEndTime = cal.date(bySettingHour: endH, minute: endM, second: 0, of: self.currentEndTime) ?? self.currentEndTime

                    self.startTimePicker.date = self.currentStartTime
                    self.endTimePicker.date = self.currentEndTime
                }

                self.updatePeriodMenu()
                self.notifyDelegateOfChanges()
            }
            actions.append(action)
        }

        periodButton.menu = UIMenu(title: "Select Period", children: actions)
    }

    @objc private func startTimeChanged() {
        currentStartTime = startTimePicker.date
        notifyDelegateOfChanges()
    }

    @objc private func endTimeChanged() {
        currentEndTime = endTimePicker.date
        notifyDelegateOfChanges()
    }

    private func notifyDelegateOfChanges() {
        delegate?.didUpdateDose(cell: self, period: currentPeriod, startTime: currentStartTime, endTime: currentEndTime)
    }
}
