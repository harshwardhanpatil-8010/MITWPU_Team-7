import UIKit

class SymptomViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dates: [DateModel] = []
    var selectedDate: Date = Date()
    
    // ADD CaseIterable HERE to fix the error
    enum Section: Int, CaseIterable {
        case calendar = 0
        case tremor = 1
        case gait = 2 // Separate case
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dates = HomeDataStore.shared.getDates()
        
        registerCells()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        autoSelectToday()
    }
    
    func registerCells() {
        collectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        collectionView.register(UINib(nibName: "tremorCard", bundle: nil), forCellWithReuseIdentifier: "tremor_cell")
        collectionView.register(UINib(nibName: "gaitCard", bundle: nil), forCellWithReuseIdentifier: "gait_cell") // Registered
        
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
    }

    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, env in
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .calendar:
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .absolute(70))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 4
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
                let calendarHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [calendarHeader]
                return section
                
            case .tremor:
                // Full width card layout
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
                return section
            case .gait:
                        // SEPARATE CASE FOR GAIT
                        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130))
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(130))
                        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                        let section = NSCollectionLayoutSection(group: group)
                        
                        // Less top inset here so it sits nicely below the Tremor card
                        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 20, trailing: 0)
                        return section
            }
        }
    }
    
    // MARK: - Helper Methods
    func autoSelectToday() {
        if let index = dates.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {
            selectedDate = dates[index].date
            DispatchQueue.main.async {
                let indexPath = IndexPath(item: index, section: 0)
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }

    func formattedDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Data Source & Delegate
extension SymptomViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        switch sectionType {
        case .calendar: return dates.count
        case .tremor: return 1
        case .gait: return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch sectionType {
        case .calendar:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalenderCollectionViewCell
            let model = dates[indexPath.row]
            let isSelected = Calendar.current.isDate(model.date, inSameDayAs: selectedDate)
            let isToday = Calendar.current.isDate(model.date, inSameDayAs: Date())
            cell.configure(with: model, isSelected: isSelected, isToday: isToday)
            return cell
            
        case .tremor:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tremor_cell", for: indexPath) as! tremorCard
            // Configuration for your tremor card
            //cell.avgLabel.text = "15%"
            cell.configure(average: "12%")
            return cell
            
        case .gait:
                // SEPARATE CASE FOR GAIT CELL
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gait_cell", for: indexPath) as! gaitCard
                cell.configure(range: "45 - 77")
                return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader && indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
            let dateString = formattedDateString(for: selectedDate)
            let isToday = Calendar.current.isDateInToday(selectedDate)
            header.configure(title: isToday ? "Today, \(dateString)" : dateString)
            header.setTitleAlignment(.center)
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == Section.calendar.rawValue {
            selectedDate = dates[indexPath.row].date
            // Reload all sections so the header AND the tremor card update
            collectionView.reloadData()
        }
    }
}
