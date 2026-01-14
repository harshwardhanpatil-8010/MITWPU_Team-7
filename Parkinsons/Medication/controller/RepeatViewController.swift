//
//  RepeatViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

protocol RepeatSelectionDelegate: AnyObject {
    func didSelectRepeatRule(_ rule: RepeatRule)
}

class RepeatViewController: UIViewController,
                            UITableViewDataSource,
                            UITableViewDelegate,
                            UITextFieldDelegate {
    
    @IBOutlet weak var tickButton: UIBarButtonItem!
    @IBOutlet weak var RepeatTableView: UITableView!
    
    weak var delegate: RepeatSelectionDelegate?
    var preselectedSchedule: RepeatRule?
    private var repeatList: [RepeatOption] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        repeatList = RepeatOption.defaultList()
        RepeatTableView.layer.cornerRadius = 25
        RepeatTableView.clipsToBounds = true
        RepeatTableView.allowsMultipleSelection = true
        RepeatTableView.delegate = self
        RepeatTableView.dataSource = self

        if let schedule = preselectedSchedule {
            restoreSelection(from: schedule)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repeatList.count
    }

    private func restoreSelection(from schedule: RepeatRule) {
        repeatList = RepeatOption.defaultList()

        switch schedule {
        case .everyday:
            if let index = repeatList.firstIndex(where: { $0.name == "Everyday" }) {
                repeatList[index].isSelected = true
            }
        case .weekly(let days):
            let weekdayMap: [Int: String] = [
                1: "Sunday",
                2: "Monday",
                3: "Tuesday",
                4: "Wednesday",
                5: "Thursday",
                6: "Friday",
                7: "Saturday"
            ]
            for day in days {
                if let name = weekdayMap[day],
                   let index = repeatList.firstIndex(where: { $0.name == name }) {
                    repeatList[index].isSelected = true
                }
            }
        case .none:
            break
        }

        RepeatTableView.reloadData()
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! RepeatTableViewCell
        
        let type = repeatList[indexPath.row]
        cell.configureCell(type: type)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tapped = repeatList[indexPath.row]

        if tapped.name == "Everyday" {
            for i in 0..<repeatList.count {
                repeatList[i].isSelected = (i == indexPath.row)
            }
        } else {
            if let everydayIndex = repeatList.firstIndex(where: { $0.name == "Everyday" }) {
                repeatList[everydayIndex].isSelected = false
            }
            repeatList[indexPath.row].isSelected.toggle()
        }

        tableView.reloadData()
    }

    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
   
    @IBAction func onTickPressed(_ sender: Any) {
        let selectedDays = repeatList.filter { $0.isSelected }.map { $0.name }
        let rule: RepeatRule

        if selectedDays.contains("Everyday") {
            rule = .everyday
        } else {
            let map: [String:Int] = [
                "Sunday":1,"Monday":2,"Tuesday":3,
                "Wednesday":4,"Thursday":5,"Friday":6,"Saturday":7
            ]
            let days = selectedDays.compactMap { map[$0] }
            rule = days.isEmpty ? .none : .weekly(days)
        }

        delegate?.didSelectRepeatRule(rule)
        navigationController?.popViewController(animated: true)
    }
}

struct RepeatOption {
    let name: String
    var isSelected: Bool
}

extension RepeatOption {
    static func defaultList() -> [RepeatOption] {
        return [
            .init(name: "Everyday", isSelected: false),
            .init(name: "Sunday", isSelected: false),
            .init(name: "Monday", isSelected: false),
            .init(name: "Tuesday", isSelected: false),
            .init(name: "Wednesday", isSelected: false),
            .init(name: "Thursday", isSelected: false),
            .init(name: "Friday", isSelected: false),
            .init(name: "Saturday", isSelected: false)
        ]
    }
}
