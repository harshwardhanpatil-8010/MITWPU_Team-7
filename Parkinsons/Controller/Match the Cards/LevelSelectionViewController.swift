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
    @IBOutlet weak var playButton: UIButton!
   
    @IBOutlet weak var calendarViewOutlet: UIView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let calendar = Calendar.current
    private var currentMonthDate = Date()
    private var daysInMonth = 0
    private var firstWeekday = 0
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false

        setupMonth()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
        }

    }

    private func setupMonth() {
        daysInMonth = calendar.range(of: .day, in: .month, for: currentMonthDate)?.count ?? 0
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonthDate))!
        firstWeekday = calendar.component(.weekday, from: firstDay) - 1

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthAndYearOutlet.text = formatter.string(from: currentMonthDate)

        collectionView.reloadData()
    }



    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        daysInMonth + firstWeekday
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DateCell",
            for: indexPath
        ) as! DateCell

        if indexPath.item < firstWeekday {
            cell.configureEmpty()
            return cell
        }

        let day = indexPath.item - firstWeekday + 1
        let date = calendar.date(bySetting: .day, value: day, of: currentMonthDate)!
        let today = calendar.startOfDay(for: Date())
        let cellDate = calendar.startOfDay(for: date)

        let currentMonth = calendar.dateComponents([.year, .month], from: today)
        let showingMonth = calendar.dateComponents([.year, .month], from: currentMonthDate)

        let isSameMonth = currentMonth.year == showingMonth.year &&
                          currentMonth.month == showingMonth.month

        let isToday = calendar.isDate(cellDate, inSameDayAs: today)

        let isPast: Bool
        if isSameMonth {
            // Only compare days inside the current month
            isPast = cellDate < today
        } else {
            // Entire month logic
            isPast = currentMonthDate < today
        }

        cell.configure(
            day: day,
            isToday: isToday,
            isPast: isPast
        )



        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        CGSize(width: collectionView.frame.width / 7,
               height: collectionView.frame.height / 6)
    }

    

        

    
//    
//    @IBAction func startButtonTapped(_ sender: UIButton) {
//        sender.isEnabled = false
//
//        let manager = DailyGameManager.shared
//        
//        if manager.isOutsideCurrentMonth(date: date) {
//           alert("This date is in future. You can't play it yet")
//            sender.isEnabled = true
//            return
//        }
//        if manager.isFuture(date: date) {
//            alert("This levels are locked")
//            sender.isEnabled = true
//            return
//        }
//        
//        if manager.isCompleted(date: date) {
//            alert("Game for this day is already completed")
//            sender.isEnabled = true
//            return
//        }
//        
//        if manager.isAttempted(date: date) {
//            alert("You already attempted this day and cannot retry")
//            sender.isEnabled = true
//            return
//        }
//        
//        
//        let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
//        
//        vc.selectedDate = date
//        vc.level = manager.level(for: date)
//        
//        navigationController?.pushViewController(vc, animated: true)
//    }
//    
//    private func alert(_ text: String) {
//        let alert = UIAlertController(title: "Not Allowed", message: text, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
//        present(alert, animated: true)
//        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
