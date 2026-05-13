import UIKit

protocol SymptomLogDetailDelegate: AnyObject {
    func symptomLogDidComplete(with ratings: [SymptomRating])
    func symptomLogDidCancel()
}

class SymptomLogDetailViewController: UIViewController {

    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: SymptomLogDetailDelegate?

    var symptoms: [SymptomRating]!

    override func viewDidLoad() {
        if self.symptoms == nil || self.symptoms.isEmpty {
            loadDefaultSymptoms()
        }
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupTableViewFromStoryboard()
    }

    private func loadDefaultSymptoms() {
        self.symptoms = SymptomType.allSorted.map { type in
            SymptomRating(
                name: type.displayName,
                iconName: type.iconName,
                selectedIntensity: .notPresent,
                type: type
            )
        }
    }

    private func setupTableViewFromStoryboard() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        tableView.register(UINib(nibName: "SymptomRatingCell", bundle: nil), forCellReuseIdentifier: "SymptomRatingCell")
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.symptomLogDidCancel()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.symptomLogDidComplete(with: symptoms)
        dismiss(animated: true, completion: nil)
    }
}

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

extension SymptomLogDetailViewController: SymptomRatingCellDelegate {
    func didSelectIntensity(_ intensity: SymptomRating.Intensity, in cell: SymptomRatingCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        symptoms[indexPath.row].selectedIntensity = intensity

    }
}
