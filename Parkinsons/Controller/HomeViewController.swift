//
//  HomeViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class HomeViewController: UIViewController,UICollectionViewDelegate {

    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var calenderCollectionView: UICollectionView!
   // @IBOutlet weak var calenderArea: CalenderCollectionViewCell!
    
    var dates: [DateModel] = []
    var selectedDate: Date = Date()
    private let floatingBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 34 // Half the height for the rounded capsule shape
        
        // Add Shadow for floating effect
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
       // setupFloatingBar()
        calenderCollectionView.dataSource = self
        calenderCollectionView.delegate = self

//        tasksTableView.dataSource = self
        calenderCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        dates = DataStore.shared.getDates()
        autoSelectToday()
        
        // Do any additional setup after loading the view.
        // Set the initial date label text (must be called after selectedDate is set in autoSelectToday)
            updateDateLabel(with: selectedDate) // <-- ADDED
    }
    func registerCells(){
        calenderCollectionView.register(UINib(nibName: "CalenderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "calendar_cell")
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { section, env in
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(60),
                heightDimension: .absolute(70)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(400),
                heightDimension: .absolute(100)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 7
            )

            //group.interItemSpacing = .fixed(12)

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 0, bottom: 30, trailing: 0)

            return section
        }
        return layout
    }
    func autoSelectToday() {
        if let index = dates.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {

            selectedDate = dates[index].date

            DispatchQueue.main.async {
                let indexPath = IndexPath(item: index, section: 0)
                self.calenderCollectionView.scrollToItem(
                    at: indexPath,
                    at: .centeredHorizontally,
                    animated: false
                )
                self.calenderCollectionView.selectItem(
                    at: indexPath,
                    animated: false,
                    scrollPosition: []
                )
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calenderCollectionView.dequeueReusableCell(withReuseIdentifier: "calendar_cell", for: indexPath) as! CalenderCollectionViewCell
    
        /// NEW
        let model = dates[indexPath.row]
        let isSelected = Calendar.current.isDate(model.date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDate(model.date, inSameDayAs: Date())
        cell.configure(with: model, isSelected: isSelected, isToday: isToday)
        /// UPTO THIS
        

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            // 1. Get the indexPath of the currently selected cell *before* we change the selectedDate.
            // This is needed to de-select (reconfigure) the old cell.
//            let oldSelectedIndexPath = self.calenderCollectionView.indexPathsForSelectedItems?.first
//
//            // 2. Update the model.
//            selectedDate = dates[indexPath.item].date
//            
//            // 3. Manually deselect the previously selected item if one exists.
//            // Although UICollectionView handles the isSelected state change, we need to manually
//            // reconfigure the *old* cell to remove its custom selection UI (systemCyan background).
//            if let oldIndexPath = oldSelectedIndexPath {
//                // Note: Deselecting *before* selection in the UICollectionView API
//                // typically only works if multi-selection is off, but for our custom
//                // UI logic in cellForItemAt, it's safer to just reload both items.
//                // If the old selection is different from the new one, deselect it.
//                if oldIndexPath != indexPath {
//                    self.calenderCollectionView.deselectItem(at: oldIndexPath, animated: false)
//                }
//            }
//            
//            // 4. Update the UI for the newly selected and previously selected cells.
//            // We only need to reload the cells whose appearance has changed.
//            var indexPathsToReload: [IndexPath] = [indexPath]
//            if let oldIndexPath = oldSelectedIndexPath, oldIndexPath != indexPath {
//                indexPathsToReload.append(oldIndexPath)
//            }
//            
//            // This is the crucial step: tell the collection view to re-run cellForItemAt
//            // for the cells that need updating (old selected and new selected).
//            self.calenderCollectionView.reloadItems(at: indexPathsToReload)
        }
    // In ViewController.swift
//    func setupFloatingBar() {
//        view.addSubview(floatingBar)
//
//        // Using 68 as an example height for a nice, chunky capsule
//        let barHeight: CGFloat = 56
//        
//        // 1. Constraints for the bar container
//        // 1. Constraints for the bar container
//        NSLayoutConstraint.activate([
//            // Position it 72 points from the TOP
//            floatingBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 72),
//            
//            // Position it 16 points from the RIGHT
//            floatingBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            
//            // Fixed height (68)
//            floatingBar.heightAnchor.constraint(equalToConstant: barHeight),
//            
//            // Fixed width (250)
//            floatingBar.widthAnchor.constraint(equalToConstant: 172)
//            
//            // REMOVE: floatingBar.bottomAnchor.constraint(...)
//            // REMOVE: floatingBar.centerXAnchor.constraint(...)
//        ])
//        
//        // 2. Add the icon buttons inside the floatingBar (Tree, Calendar, Profile)
//        let stackView = UIStackView()
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually // Distributes the three items evenly
//        floatingBar.addSubview(stackView)
//        
//        NSLayoutConstraint.activate([
//            stackView.leadingAnchor.constraint(equalTo: floatingBar.leadingAnchor, constant: 10),
//            stackView.trailingAnchor.constraint(equalTo: floatingBar.trailingAnchor, constant: -10),
//            stackView.topAnchor.constraint(equalTo: floatingBar.topAnchor),
//            stackView.bottomAnchor.constraint(equalTo: floatingBar.bottomAnchor)
//        ])
//        
//        // Function to create an icon button
//        func createIconButton(systemName: String) -> UIButton {
//            let button = UIButton(type: .system)
//            
//            // CHANGE IS HERE: Use a lighter weight for the symbol configuration
//            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .light) // Changed from .regular
//            
//            let image = UIImage(systemName: systemName, withConfiguration: config)
//            button.setImage(image, for: .normal)
//            button.tintColor = .black // Icon color
//            return button
//        }
//        
//        // Add the three icons
//        let treeButton = createIconButton(systemName: "tree.fill") // Replace if you have a custom asset
//        let calendarButton = createIconButton(systemName: "calendar")
//        let profileButton = createIconButton(systemName: "person.circle.fill")
//        
//        stackView.addArrangedSubview(treeButton)
//        stackView.addArrangedSubview(calendarButton)
//        stackView.addArrangedSubview(profileButton)
//        
//        // Optional: Add target actions to the buttons
//        // calendarButton.addTarget(self, action: #selector(calendarTapped), for: .touchUpInside)
//    }
}
extension HomeViewController {
    func formattedDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy" // e.g., 28 November 2025
        return formatter.string(from: date)
    }
    
    // Function to update the todayDate label
    func updateDateLabel(with date: Date) {
        let dateString = formattedDateString(for: date)
        
        // Check if the selected date is today
        let isToday = Calendar.current.isDateInToday(date)
        
        if isToday {
            todayDate.text = "Today, \(dateString)"
        } else {
            todayDate.text = dateString
        }
    }
}
