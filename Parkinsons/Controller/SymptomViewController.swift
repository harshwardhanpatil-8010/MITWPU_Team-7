import UIKit

class SymptomViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    // @IBOutlet weak var collectionView: UICollectionView!
    
    // 1. Data properties needed for the calendar
    var dates: [DateModel] = []
    var selectedDate: Date = Date()
    
    // The section enum to keep logic consistent
    enum Section: Int {
        case calendar
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. Setup Data
        dates = HomeDataStore.shared.getDates()
        
        // 3. Setup CollectionView
        registerCells()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        autoSelectToday()
    }
    
    // MARK: - Registration (Exact same as HomeController)
    func registerCells() {
        collectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
        
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )
    }

    // MARK: - Layout (The exact ".calendar" case from generateLayout)
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, env in
            // Item
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .absolute(70))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group (7 items for a week view)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
            
            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = 4
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            
            // Header (Date display)
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
            let calendarHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            calendarHeader.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [calendarHeader]
            
            return section
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalenderCollectionViewCell
        let model = dates[indexPath.row]
        
        let isSelected = Calendar.current.isDate(model.date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDate(model.date, inSameDayAs: Date())
        
        cell.configure(with: model, isSelected: isSelected, isToday: isToday)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! SectionHeaderView
        
        let dateString = formattedDateString(for: selectedDate)
        let isToday = Calendar.current.isDateInToday(selectedDate)
        header.configure(title: isToday ? "Today, \(dateString)" : dateString)
        header.setTitleAlignment(.center)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDate = dates[indexPath.row].date
        // Refresh the calendar section to update the selection styling and header text
        collectionView.reloadSections(IndexSet(integer: 0))
    }
}
