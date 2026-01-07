//
//  LevelSelectionViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class LevelSelectionViewController: UIViewController,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var monthAndYearOutlet: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2
        return c
    }()

    private let today = Calendar(identifier: .gregorian).startOfDay(for: Date())
    private var firstDayOfMonth: Date!
    private var firstWeekdayOffset = 0
    private var daysInMonth = 0
    private var selectedDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false

        configureLayout()
        setupMonth()
    }

    private func configureLayout() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let width = collectionView.bounds.width / 7
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.estimatedItemSize = .zero
    }

    private func setupMonth() {
        let now = Date()

        let comps = calendar.dateComponents([.year, .month], from: now)
        firstDayOfMonth = calendar.date(from: comps)!

        daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count

        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        firstWeekdayOffset = (weekday - calendar.firstWeekday + 7) % 7

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "MMMM yyyy"
        monthAndYearOutlet.text = formatter.string(from: firstDayOfMonth)

        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        daysInMonth + firstWeekdayOffset
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DateCell",
            for: indexPath
        ) as! DateCell

        if indexPath.item < firstWeekdayOffset {
            cell.configureEmpty()
            return cell
        }

        let day = indexPath.item - firstWeekdayOffset + 1
        let date = calendar.date(byAdding: .day,
                                 value: day - 1,
                                 to: firstDayOfMonth)!

        let cellDate = calendar.startOfDay(for: date)

        let isToday = calendar.isDate(cellDate, inSameDayAs: today)
        let isFuture = cellDate > today
        let isCompleted = DailyGameManager.shared.isCompleted(date: cellDate)
        let isSelected = selectedDate != nil &&
            calendar.isDate(cellDate, inSameDayAs: selectedDate!)
        let showTodayOutline = isToday && selectedDate != nil && !isSelected

        cell.configure(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            isCompleted: isCompleted,
            showTodayOutline: showTodayOutline,
            enabled: !isFuture
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        guard indexPath.item >= firstWeekdayOffset else { return }

        let day = indexPath.item - firstWeekdayOffset + 1
        let date = calendar.date(byAdding: .day,
                                 value: day - 1,
                                 to: firstDayOfMonth)!

        let cellDate = calendar.startOfDay(for: date)

        if cellDate > today { return }

        selectedDate = cellDate
        collectionView.reloadData()
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let date = selectedDate else { return }
        if DailyGameManager.shared.isCompleted(date: date) { return }

        let vc = storyboard!.instantiateViewController(
            withIdentifier: "GameViewController"
        ) as! GameViewController

        vc.selectedDate = date
        vc.level = DailyGameManager.shared.level(for: date)

        navigationController?.pushViewController(vc, animated: true)
    }
}
