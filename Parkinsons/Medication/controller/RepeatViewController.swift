//
//  RepeatViewController.swift
//  Parkinsons
//

import UIKit

protocol RepeatSelectionDelegate: AnyObject {
    func didSelectSchedule(type: String, days: [Int]?)
}

class RepeatViewController: UIViewController,
                            UITableViewDataSource,
                            UITableViewDelegate {

    @IBOutlet weak var tickButton: UIBarButtonItem!
    @IBOutlet weak var repeatTableView: UITableView!

    weak var delegate: RepeatSelectionDelegate?

    // From AddMedicationVC
    var preselectedType: String?
    var preselectedDays: [Int]?

    private var repeatList: [RepeatOption] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        repeatList = RepeatOption.defaultList()

        repeatTableView.delegate = self
        repeatTableView.dataSource = self
        repeatTableView.layer.cornerRadius = 25
        repeatTableView.clipsToBounds = true

        restoreSelection()
    }

    // MARK: - Restore Selection (Edit Mode)

    private func restoreSelection() {
        guard let type = preselectedType else { return }

        if type == "everyday" {
            if let index = repeatList.firstIndex(where: { $0.name == "Everyday" }) {
                repeatList[index].isSelected = true
            }
        }

        if type == "weekly", let days = preselectedDays {
            let weekdayMap: [Int: String] = [
                1: "Every Sunday",
                2: "Every Monday",
                3: "Every Tuesday",
                4: "Every Wednesday",
                5: "Every Thursday",
                6: "Every Friday",
                7: "Every Saturday"
            ]

            for day in days {
                if let name = weekdayMap[day],
                   let index = repeatList.firstIndex(where: { $0.name == name }) {
                    repeatList[index].isSelected = true
                }
            }
        }

        repeatTableView.reloadData()
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        repeatList.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! RepeatTableViewCell

        cell.configureCell(type: repeatList[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let tapped = repeatList[indexPath.row]

        if tapped.name == "Everyday" {
            for i in 0..<repeatList.count {
                repeatList[i].isSelected = (i == indexPath.row)
            }
        } else {
            // Unselect Everyday if selecting specific days
            if let everydayIndex = repeatList.firstIndex(where: { $0.name == "Everyday" }) {
                repeatList[everydayIndex].isSelected = false
            }

            repeatList[indexPath.row].isSelected.toggle()
        }

        tableView.reloadData()
    }

    // MARK: - Buttons

    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onTickPressed(_ sender: Any) {

        let selectedNames = repeatList
            .filter { $0.isSelected }
            .map { $0.name }

        // Everyday
        if selectedNames.contains("Everyday") {
            delegate?.didSelectSchedule(type: "everyday", days: nil)
            navigationController?.popViewController(animated: true)
            return
        }

        // Weekly
        let map: [String: Int] = [
            "Every Sunday": 1,
            "Every Monday": 2,
            "Every Tuesday": 3,
            "Every Wednesday": 4,
            "Every Thursday": 5,
            "Every Friday": 6,
            "Every Saturday": 7
        ]

        let days = selectedNames.compactMap { map[$0] }

        if days.isEmpty {
            delegate?.didSelectSchedule(type: "none", days: nil)
        } else {
            delegate?.didSelectSchedule(type: "weekly", days: days.sorted())
        }

        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Model

struct RepeatOption {
    let name: String
    var isSelected: Bool
}

extension RepeatOption {
    static func defaultList() -> [RepeatOption] {
        return [
            .init(name: "Everyday", isSelected: false),
            .init(name: "Every Sunday", isSelected: false),
            .init(name: "Every Monday", isSelected: false),
            .init(name: "Every Tuesday", isSelected: false),
            .init(name: "Every Wednesday", isSelected: false),
            .init(name: "Every Thursday", isSelected: false),
            .init(name: "Every Friday", isSelected: false),
            .init(name: "Every Saturday", isSelected: false)
        ]
    }
}
