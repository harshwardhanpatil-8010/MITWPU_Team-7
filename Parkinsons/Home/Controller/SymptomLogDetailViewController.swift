import UIKit

protocol SymptomLogDetailDelegate: AnyObject {
    func symptomLogDidComplete(with ratings: [SymptomRating])
    func symptomLogDidCancel()
}

class SymptomLogDetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    weak var delegate: SymptomLogDetailDelegate?
    
    var symptoms: [SymptomRating]!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        if self.symptoms == nil || self.symptoms.isEmpty {
            loadDefaultSymptoms()
        }
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
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
    
    private func setupTableViewFromStoryboard() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        // Register the custom cell created from XIB
        tableView.register(UINib(nibName: "SymptomRatingCell", bundle: nil), forCellReuseIdentifier: "SymptomRatingCell")
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.symptomLogDidCancel()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.symptomLogDidComplete(with: symptoms)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

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
        return 130
    }
}

// MARK: - SymptomRatingCellDelegate

extension SymptomLogDetailViewController: SymptomRatingCellDelegate {
    func didSelectIntensity(_ intensity: SymptomRating.Intensity, in cell: SymptomRatingCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Update the data model
        symptoms[indexPath.row].selectedIntensity = intensity
        
        // Instead of reloading the whole row (which can flicker),
        // just let the cell handle its own internal UI update.
        // tableView.reloadRows(at: [indexPath], with: .none) // Comment this out
    }
}
