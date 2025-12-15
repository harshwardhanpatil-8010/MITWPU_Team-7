import UIKit

// MARK: - Delegate Protocol (For sending data back to HomeViewController)

protocol SymptomLogDetailDelegate: AnyObject {
    func symptomLogDidComplete(with ratings: [SymptomRating])
    func symptomLogDidCancel()
}

// MARK: - View Controller Implementation

class SymptomLogDetailViewController: UIViewController {
    
    // MARK: - Storyboard Outlets
    
    // Connect the view containing the "Mild" to "Not present" key/legend
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Properties
    
    weak var delegate: SymptomLogDetailDelegate?
    
    // Data Source: This array tracks all user selections
//    var symptoms: [SymptomRating] = [
//        SymptomRating(name: "Slowed Movement", iconName: "SlowedMovement"),
//        SymptomRating(name: "Tremor", iconName: "tremor"),
//        SymptomRating(name: "Loss of Balance", iconName: "lossOfBalance"),
//        SymptomRating(name: "Facial Stiffness", iconName: "stiffFace"),
//        SymptomRating(name: "Body Stiffness", iconName: "bodyStiffness"),
//        SymptomRating(name: "Gait Disturbance", iconName: "walking"),
//        SymptomRating(name: "Insomnia", iconName: "insomnia")
//    ]
    var symptoms: [SymptomRating]!
    
    // UI Elements
  //  private let tableView = UITableView()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        if self.symptoms == nil || self.symptoms.isEmpty {
                    loadDefaultSymptoms()
                }
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Ensure the navigation title is set
//        navigationItem.title = "Select symptoms faced"
        
        //setupTableView()
        setupTableViewFromStoryboard()
    }
    
    // MARK: - UI Setup
    private func loadDefaultSymptoms() {
            self.symptoms = [
                SymptomRating(name: "Slowed Movement", iconName: "SlowedMovement"),
                SymptomRating(name: "Tremor", iconName: "tremor"),
                SymptomRating(name: "Loss of Balance", iconName: "lossOfBalance"),
                SymptomRating(name: "Facial Stiffness", iconName: "stiffFace"),
                SymptomRating(name: "Body Stiffness", iconName: "bodyStiffness"),
                SymptomRating(name: "Gait Disturbance", iconName: "walking"),
                SymptomRating(name: "Insomnia", iconName: "insomnia")
            ]
        }
//    private func setupTableView() {
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.separatorStyle = .none
//        
//        // Register the custom cell created from XIB
//        tableView.register(UINib(nibName: "SymptomRatingCell", bundle: nil), forCellReuseIdentifier: "SymptomRatingCell")
//        
//        // The table view starts below the header/legend view
//        let topAnchor = headerContainerView?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 140),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    } 
    private func setupTableViewFromStoryboard() {
            // Since the TableView is connected via outlet and delegates via Storyboard,
            // we just need to register the cell and configure its constraints.
            
            // Set the data source and delegate one more time for safety (optional if done in Storyboard)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
            
            // Register the custom cell created from XIB (Still required)
            tableView.register(UINib(nibName: "SymptomRatingCell", bundle: nil), forCellReuseIdentifier: "SymptomRatingCell")
            
            // ⭐️ IMPORTANT: If you set constraints in the Storyboard, this code is NOT needed.
            // If your Table View is not constrained in the Storyboard, you must add constraints.
            // If you keep the Table View programmatic constraints, ensure you remove the Storyboard constraints.
            
            // If you are using Auto Layout in the Storyboard, DELETE this block.
            /*
            tableView.translatesAutoresizingMaskIntoConstraints = false
            let topAnchor = headerContainerView?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: topAnchor, constant: 140),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            */
        }
    // MARK: - Storyboard Actions (Connect your Cancel/Done buttons here)
    
    /**
     ACTION: Connect your LEFT Bar Button Item (the Cross/X) to this method.
     Result: Closes the modal and notifies the delegate that the action was canceled.
    */
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.symptomLogDidCancel()
        dismiss(animated: true, completion: nil)
    }

    /**
     ACTION: Connect your RIGHT Bar Button Item (the Tick/Checkmark) to this method.
     Result: Saves the data via the delegate and closes the modal.
    */
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        // 1. Send the final symptoms array back to the delegate (the "save" action)
        delegate?.symptomLogDidComplete(with: symptoms)
        // 2. Close the modal
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate (No changes needed)

extension SymptomLogDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptoms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomRatingCell", for: indexPath) as? SymptomRatingCell else {
            return UITableViewCell()
        }
        
        let rating = symptoms[indexPath.row]
        
        cell.delegate = self
        cell.configure(with: rating)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

// MARK: - SymptomRatingCellDelegate (Handles cell button taps - No changes needed)

extension SymptomLogDetailViewController: SymptomRatingCellDelegate {
    func didSelectIntensity(_ intensity: SymptomRating.Intensity, in cell: SymptomRatingCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        symptoms[indexPath.row].selectedIntensity = intensity
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
