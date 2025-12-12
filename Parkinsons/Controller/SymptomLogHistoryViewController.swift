import UIKit

class SymptomLogHistoryViewController: UIViewController {

    // MARK: - Data Source
    
    // ⭐️ Holds the single log entry for today ⭐️
    var todayLogEntry: SymptomLogEntry?
    
    // MARK: - UI Elements
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ⭐️ IMPORTANT: Ensure the view is white background for modal look ⭐️
        view.backgroundColor = .systemBackground
        
        // ⭐️ Nav Bar setup REMOVED as requested ⭐️
        setupTableView()
        
        // Placeholder data to test the display
//        if todayLogEntry == nil {
//            loadPlaceholderData()
//        }
    }
    
    // ⭐️ setupNavigationBar() function REMOVED as requested ⭐️

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        
        // ⭐️ REGISTER THE CUSTOM DETAIL CELL ⭐️
        tableView.register(UINib(nibName: SymptomDetailCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SymptomDetailCell.reuseIdentifier)
        
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none // Optional: removes lines between cells
        
        // ⭐️ Constraints for TableView - Use full view, but ensure a top offset if needed ⭐️
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20), // Top padding
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // ⭐️ backButtonTapped() function REMOVED as requested (no nav bar) ⭐️
    
//    private func loadPlaceholderData() {
//        // This simulates loading today's data
//        let sampleRatings: [SymptomRating] = [
//            SymptomRating(name: "Tremor", iconName: "hand.raised.fill", selectedIntensity: .mild),
//            SymptomRating(name: "Loss of Balance", iconName: "figure.walk", selectedIntensity: .moderate),
//            SymptomRating(name: "Gait Disturbance", iconName: "figure.roll", selectedIntensity: .notPresent),
//            SymptomRating(name: "Facial Stiffness", iconName: "face.dashed", selectedIntensity: .severe)
//        ]
//        todayLogEntry = SymptomLogEntry(date: Date(), ratings: sampleRatings)
//    }
}

// MARK: - UITableViewDataSource

extension SymptomLogHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Only show cells for the single log entry
        return todayLogEntry?.ratings.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SymptomDetailCell.reuseIdentifier, for: indexPath) as? SymptomDetailCell,
              let rating = todayLogEntry?.ratings[indexPath.row] else {
            return UITableViewCell()
        }
        
        // Configure using the custom cell
        cell.configure(with: rating)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
// Extension is empty or removed as there are no row taps for navigation.
