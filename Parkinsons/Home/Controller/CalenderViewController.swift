import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var sections: [MonthSection] = []
    var selectedDate: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarData()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToToday()
    }

    func scrollToToday() {
        let calendar = Calendar.current
        for (sectionIndex, section) in sections.enumerated() {
            if let dayIndex = section.days.firstIndex(where: { !$0.isDummy && calendar.isDateInToday($0.date) }) {
                let indexPath = IndexPath(item: dayIndex, section: sectionIndex)
                collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                break
            }
        }
    }

    func setupCalendarData() {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        for month in 1...12 {
            let components = DateComponents(year: currentYear, month: month, day: 1)
            guard let startDate = calendar.date(from: components),
                  let range = calendar.range(of: .day, in: .month, for: startDate) else { continue }
            
            // Calculate offset (0 for Sunday, 1 for Monday...)
            // Based on your image starting with Sunday (S)
            let firstWeekday = calendar.component(.weekday, from: startDate)
            let offset = firstWeekday - 1
            
            var monthDays: [DayModel] = []
            
            // 1. Add Dummy Days to shift the 1st of the month to the correct column
            for _ in 0..<offset {
                monthDays.append(DayModel(date: Date.distantPast, isDummy: true))
            }
            
            // 2. Add Actual Days
            for day in range {
                var dComp = components
                dComp.day = day
                if let date = calendar.date(from: dComp) {
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    monthDays.append(DayModel(date: date, isSelected: isSelected, isDummy: false))
                }
            }
            
            let monthName = DateFormatter().monthSymbols[month-1]
            sections.append(MonthSection(monthName: monthName, days: monthDays))
        }
    }

//    private func setupCollectionView() {
//        // Register Cell
//        collectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
//
//        // Register Header using the specific long filename from your project
//        let headerNib = UINib(nibName: "MonthHeaderViewCollectionReusableView", bundle: nil)
//        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MonthHeaderView")
//
//        collectionView.dataSource = self
//        collectionView.delegate = self
//
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 15
//        layout.minimumInteritemSpacing = 2
//        layout.sectionHeadersPinToVisibleBounds = true
//        layout.sectionInset = UIEdgeInsets(top: -22, left: 0, bottom: 30, right: 0)
//        collectionView.collectionViewLayout = layout
//    }
//    private func setupCollectionView() {
//        // Register Cell and Header (keeping your current registration)
//        collectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
//
//        let headerNib = UINib(nibName: "MonthHeaderViewCollectionReusableView", bundle: nil)
//        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MonthHeaderView")
//
//        collectionView.dataSource = self
//        collectionView.delegate = self
//
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//
//        // 1. Center the grid: We calculate insets so the leftover space is equal on both sides
//        // 2. Add space between months: set the bottom inset to 40
//        layout.sectionHeadersPinToVisibleBounds = true
//        layout.sectionInset = UIEdgeInsets(top: -20, left: 0, bottom: 40, right: 0)
//
//        layout.minimumLineSpacing = 10
//        layout.minimumInteritemSpacing = 0
//        layout.sectionHeadersPinToVisibleBounds = true
//
//        collectionView.collectionViewLayout = layout
//    }
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        
        let headerNib = UINib(nibName: "MonthHeaderViewCollectionReusableView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MonthHeaderView")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // Keeping the scrolling as it is
        
        // Using leading/trailing: 8 (from your compositional code snippet)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
        
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 0
        layout.sectionHeadersPinToVisibleBounds = true
        
        collectionView.collectionViewLayout = layout
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalenderCollectionViewCell
        let dayData = sections[indexPath.section].days[indexPath.item]
        
        // Hide dummy cells
        cell.isHidden = dayData.isDummy
        if dayData.isDummy { return cell }
        
        let dateModel = DateModel(date: dayData.date, dayString: "", dateString: dayData.dayNumber)
        let isToday = Calendar.current.isDateInToday(dayData.date)
        
        cell.configure(with: dateModel, isSelected: dayData.isSelected, isToday: isToday)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MonthHeaderView", for: indexPath) as! MonthHeaderViewCollectionReusableView
        header.titleLabel.text = sections[indexPath.section].monthName
        return header
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        // Divide by 7 for the grid columns
////        let width = collectionView.frame.width / 6.5
//        let width: CGFloat = 55
//        return CGSize(width: width, height: 50)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        // Use the layout passed in to get section insets if it's a flow layout
//        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
//        let leftInset = flowLayout?.sectionInset.left ?? 0
//        let rightInset = flowLayout?.sectionInset.right ?? 0
//        let totalPadding = leftInset + rightInset
//        let availableWidth = collectionView.frame.width - totalPadding
//
//        // Divide exactly by 7 columns
//        let width = floor(availableWidth / 7)
//        return CGSize(width: width, height: 60)
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        // (Screen Width - Left Inset - Right Inset) / 7
//        let width = (collectionView.frame.width - 32) / 7
//        return CGSize(width: width, height: 65) // Increased height for better capsule shape
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Math to ensure 7 items per row with 8pt padding on each side
        // (Total Width - Left Inset - Right Inset) / 7
        let availableWidth = collectionView.frame.width - 33
        let width = availableWidth / 7
        
        // Use the 65 height from your compositional layout snippet
        return CGSize(width: width, height: 65)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayData = sections[indexPath.section].days[indexPath.item]
        if dayData.isDummy { return }

        // Logic for single selection
        for s in 0..<sections.count {
            for d in 0..<sections[s].days.count {
                sections[s].days[d].isSelected = false
            }
        }
        sections[indexPath.section].days[indexPath.item].isSelected = true
        collectionView.reloadData()
        
        presentSummary(for: dayData.date)
    }
    
    private func presentSummary(for date: Date) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController else { return }
        summaryVC.dateToDisplay = date
        let navController = UINavigationController(rootViewController: summaryVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
}
