// SymptomLogHistoryViewController.swift

import UIKit

class SymptomLogHistoryViewController: UIViewController {

    // MARK: - Data Source
    
    // This array will hold all the daily log entries to display in the table view
    var logEntries: [SymptomLogEntry] = []
    
    // MARK: - UI Elements
    
    private let tableView = UITableView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        
        // ⭐️ Placeholder Data for Testing ⭐️
        // In a real app, this would be loaded from a database.
        if logEntries.isEmpty {
            loadPlaceholderData()
        }
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        navigationItem.title = "Symptom Log History"
        
        // Left Button: Dismiss/Back
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register a standard cell for simplicity initially
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LogHistoryCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    // MARK: - Actions

    @objc func backButtonTapped() {
        // ⭐️ CRITICAL CHANGE: Use dismiss(animated:) instead of popViewController ⭐️
        // This closes the modal sheet.
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Placeholder Data (Remove later)
    
    private func loadPlaceholderData() {
        let sampleRatings: [SymptomRating] = [
            SymptomRating(name: "Tremor", iconName: nil, selectedIntensity: .mild),
            SymptomRating(name: "Loss of Balance", iconName: nil, selectedIntensity: .moderate),
            SymptomRating(name: "Gait Disturbance", iconName: nil, selectedIntensity: .notPresent)
        ]
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        logEntries.append(SymptomLogEntry(date: yesterday, ratings: sampleRatings))
        logEntries.append(SymptomLogEntry(date: Date(), ratings: sampleRatings))
    }
}

// MARK: - UITableViewDataSource

extension SymptomLogHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogHistoryCell", for: indexPath)
        let entry = logEntries[indexPath.row]
        
        // Format the date for the cell title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        cell.textLabel?.text = dateFormatter.string(from: entry.date)
        cell.accessoryType = .disclosureIndicator // Arrow to indicate tapping opens detail
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SymptomLogHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // TODO: Navigate to a detailed view of the specific log entry
        print("Tapped on log entry for: \(logEntries[indexPath.row].date)")
    }
}
