import UIKit

class SymptomLogHistoryViewController: UIViewController , SymptomLogDetailDelegate {

    weak var updateCompletionDelegate: SymptomLogDetailDelegate?
    var todayLogEntry: SymptomLogEntry? {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupTableViewFromStoryboard()
        setupCustomHeader()
    }
    
    private func setupCustomHeader() {
    }
    
    private func updateTitle() {
        let date = todayLogEntry?.date ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        
        if Calendar.current.isDateInToday(date) {
            titleLabel.text = "Symptoms Faced (Today)"
        } else {
            titleLabel.text = "Symptoms Faced (\(formatter.string(from: date)))"
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func editButtonTapped(_ sender: Any) {
        guard let currentLog = todayLogEntry else {
            print("Cannot edit: No current log entry available.")
            return
        }
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        
        guard let symptomVC = storyboard.instantiateViewController(withIdentifier: "SymptomLogDetailViewController") as? SymptomLogDetailViewController else {
            print("Error: Could not instantiate SymptomLogDetailViewController.")
            return
        }
        
        symptomVC.symptoms = currentLog.ratings
        symptomVC.delegate = self
        
        let navController = UINavigationController(rootViewController: symptomVC)
        navController.modalPresentationStyle = .pageSheet
        
        self.present(navController, animated: true, completion: nil)
    }
    
    private func setupTableViewFromStoryboard() {
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: SymptomDetailCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SymptomDetailCell.reuseIdentifier)
        
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
    }
}

extension SymptomLogHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayLogEntry?.ratings.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SymptomDetailCell.reuseIdentifier, for: indexPath) as? SymptomDetailCell,
              let rating = todayLogEntry?.ratings[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: rating, isEditable: false)
        
        return cell
    }
}

extension SymptomLogHistoryViewController {
    
    func symptomLogDidComplete(with ratings: [SymptomRating]) {
        self.presentedViewController?.dismiss(animated: true) {

            let newLogEntry = SymptomLogEntry(date: self.todayLogEntry?.date ?? Date(), ratings: ratings)

            SymptomLogManager.shared.saveLogEntry(newLogEntry)

            self.todayLogEntry = newLogEntry

            self.updateCompletionDelegate?.symptomLogDidComplete(with: ratings)
        }
    }
    
    func symptomLogDidCancel() {
    }
}
