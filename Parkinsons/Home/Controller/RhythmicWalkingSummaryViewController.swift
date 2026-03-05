import UIKit

class RhythmicWalkingSummaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var closeBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Set the delegates so the table knows where to get data
        tableView.dataSource = self
        tableView.delegate = self
        
        // Optional: Match the styling from the previous screen
        tableView.layer.cornerRadius = 30
        tableView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh the data whenever the view appears
        tableView.reloadData()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataStore.shared.sessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Ensure the identifier "sessionCell" matches your Storyboard cell identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
        
        let session = DataStore.shared.sessions[indexPath.row]
        let walked = session.elapsedSeconds
        let hrs  = walked / 3600
        let mins = walked % 3600 / 60
        let secs = walked % 60
        
        // Identical formatting logic
        if hrs == 0 {
            cell.textLabel?.text = "Session \(session.sessionNumber)\t\t\t\t\t\t  \(mins)min \(secs)s"
        } else {
            cell.textLabel?.text = "Session \(session.sessionNumber)\t\t\t\t\t\t  \(hrs)hrs \(mins)min"
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Navigate to the specific details of this session if needed
        let selectedSession = DataStore.shared.sessions[indexPath.row]
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
//        if let summaryVC = storyboard.instantiateViewController(withIdentifier: "SessionSummaryVC") as? SessionSummaryViewController {
//            summaryVC.sessionData = selectedSession
//            let nav = UINavigationController(rootViewController: summaryVC)
//            nav.modalPresentationStyle = .formSheet
//            present(nav, animated: true)
 //       }
    }
}
