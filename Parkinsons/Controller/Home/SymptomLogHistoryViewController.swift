import UIKit

class SymptomLogHistoryViewController: UIViewController , SymptomLogDetailDelegate {

    // MARK: - Data Source
    
    weak var updateCompletionDelegate: SymptomLogDetailDelegate?
    // ⭐️ Holds the single log entry for today ⭐️
    var todayLogEntry: SymptomLogEntry? {
        didSet {
            // Ensure the table view is reloaded if data changes (e.g., after editing)
            if isViewLoaded {
                tableView.reloadData()
                //updateTitle() // Update the title when data is set
            }
        }
    }
    
    // MARK: - UI Elements
    @IBOutlet weak var tableView: UITableView!
   // private let tableView = UITableView()

    // ⭐️ Custom Header Outlets/Actions ⭐️
    // 1. Label outlet remains for the dynamic title
    @IBOutlet weak var titleLabel: UILabel!
    
    // 2. Bar Button Item Outlets (Optional: If you need to change properties dynamically,
    //    but Actions are sufficient for simple taps)
    // @IBOutlet weak var closeBarButton: UIBarButtonItem!
    // @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupTableViewFromStoryboard()
        //setupTableView()
        setupCustomHeader() // Now just sets the initial title
    }
    
    // MARK: - Custom Header Setup (Simplified)
    
    private func setupCustomHeader() {
        // Only set the initial title here, actions are connected via IBAction
        //updateTitle()
    }
    
    private func updateTitle() {
        let date = todayLogEntry?.date ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy" // e.g., 12 December 2025
        
        if Calendar.current.isDateInToday(date) {
            titleLabel.text = "Symptoms Faced (Today)"
        } else {
            titleLabel.text = "Symptoms Faced (\(formatter.string(from: date)))"
        }
    }
    
    // MARK: - Bar Button Actions ⭐️ NEW IB ACTIONS ⭐️
    
    /**
     ACTION: Connect your Left Bar Button Item (Close/X) to this method.
     */
    @IBAction func cancelButtonTapped(_ sender: Any) {
        // This dismisses the modal view. Use Any since it could be a UIBarButtonItem or a regular button.
        dismiss(animated: true, completion: nil)
    }

    /**
     ACTION: Connect your Right Bar Button Item (Edit) to this method.
     */
    @IBAction func editButtonTapped(_ sender: Any) {
        guard let currentLog = todayLogEntry else {
            print("Cannot edit: No current log entry available.")
            return
        }
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil) // Assuming SymptomLogDetailViewController is in "Home.storyboard"
        
        guard let symptomVC = storyboard.instantiateViewController(withIdentifier: "SymptomLogDetailViewController") as? SymptomLogDetailViewController else {
            print("Error: Could not instantiate SymptomLogDetailViewController.")
            return
        }
        
        // 1. Pass the *current* ratings to the editing view controller
        symptomVC.symptoms = currentLog.ratings
        
        // 2. Set the delegate so this VC can receive the updated log after saving
        symptomVC.delegate = self
        
        // 3. Present the editing view controller modally (wrapped in a Navigation Controller for its Save/Cancel buttons)
        let navController = UINavigationController(rootViewController: symptomVC)
        navController.modalPresentationStyle = .pageSheet
        
        self.present(navController, animated: true, completion: nil)
    }
    
    // MARK: - Table View Setup (Constraint kept at 128)

//    private func setupTableView() {
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.dataSource = self
//        
//        // ⭐️ REGISTER THE CUSTOM DETAIL CELL ⭐️
//        tableView.register(UINib(nibName: SymptomDetailCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SymptomDetailCell.reuseIdentifier)
//        
//        tableView.rowHeight = 60.0
//        tableView.separatorStyle = .none // Optional: removes lines between cells
//        
//        // ⭐️ Constraints for TableView - Top padding set to 128 as requested ⭐️
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 160), // Top padding
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
    private func setupTableViewFromStoryboard() {
            // Since the TableView and its delegates are connected via Storyboard,
            // we only need to register the custom cell, which is loaded from a NIB.
            
            // This ensures the delegates are set even if not done in Storyboard (good safety)
            tableView.dataSource = self
            
            // Register the custom detail cell (MUST be done if using XIB/NIB)
            tableView.register(UINib(nibName: SymptomDetailCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SymptomDetailCell.reuseIdentifier)
            
            tableView.rowHeight = 60.0
            tableView.separatorStyle = .none
            
            // ⭐️ IMPORTANT: The Auto Layout constraints are now handled by the Storyboard.
            // We delete the entire NSLayoutConstraint.activate([...]) block.
        }
    
}

// MARK: - UITableViewDataSource

extension SymptomLogHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

// MARK: - SymptomLogDetailDelegate

extension SymptomLogHistoryViewController {
    
    func symptomLogDidComplete(with ratings: [SymptomRating]) {
            // 1. Dismiss the modal editing view
            self.presentedViewController?.dismiss(animated: true) {

                // 2. Create the new log entry
                let newLogEntry = SymptomLogEntry(date: self.todayLogEntry?.date ?? Date(), ratings: ratings)

                // 3. Save the updated entry (This saves to persistence)
                SymptomLogManager.shared.saveLogEntry(newLogEntry) // Assumed working

                // 4. Update the local data source and reload the table view (This updates the History VC's UI)
                self.todayLogEntry = newLogEntry

                // 5. ⭐️ CRITICAL FIX: Inform the HomeViewController that the log was completed/updated ⭐️
                self.updateCompletionDelegate?.symptomLogDidComplete(with: ratings)
            }
        }
    
    func symptomLogDidCancel() {
        // The modal is dismissed inside the SymptomLogDetailViewController.
    }
}
