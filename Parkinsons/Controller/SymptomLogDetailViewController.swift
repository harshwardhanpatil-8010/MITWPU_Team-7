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
    
    // MARK: - Properties
    
    weak var delegate: SymptomLogDetailDelegate?
    
    // Data Source: This array tracks all user selections
    var symptoms: [SymptomRating] = [
        SymptomRating(name: "Slowed Movement", iconName: "running_man"),
        SymptomRating(name: "Tremor", iconName: "hand_tremor"),
        SymptomRating(name: "Loss of Balance", iconName: "person_balance"),
        SymptomRating(name: "Facial Stiffness", iconName: "face.smiling"),
        SymptomRating(name: "Body Stiffness", iconName: "figure.walk"),
        SymptomRating(name: "Gait Disturbance", iconName: "figure.roll")
    ]
    
    // UI Elements
    private let tableView = UITableView()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Ensure the navigation title is set
//        navigationItem.title = "Select symptoms faced"
        
        setupTableView()
    }
    
    // MARK: - UI Setup
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        // Register the custom cell created from XIB
        tableView.register(UINib(nibName: "SymptomRatingCell", bundle: nil), forCellReuseIdentifier: "SymptomRatingCell")
        
        // The table view starts below the header/legend view
        let topAnchor = headerContainerView?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 200),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
