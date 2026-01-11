import UIKit
import Foundation

final class MainMedicationViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var medSegment: UISegmentedControl!
    @IBOutlet weak var medicationCollectionView: UICollectionView!

    // MARK: - Segment Type
    enum SegmentType {
        case today
        case myMedication
    }

    // MARK: - Properties
    private let todayViewModel = TodayMedicationViewModel()
    private var currentSegment: SegmentType = .today
    private var myMedications: [Medication] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadMedications()
        updateUIForSegment()
        self.definesPresentationContext = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMedications()
    }

    // MARK: - Data
    private func loadMedications() {
        myMedications = MedicationDataStore.shared.medications

        if currentSegment == .today {
            todayViewModel.loadTodayMedications(from: myMedications)
        }

        medicationCollectionView.reloadData()
    }

    // MARK: - Setup
//    private func updateDose(_ dose: TodayDoseItem, status: DoseLogStatus) {
//        MedicationDataStore.shared.updateDoseStatus(
//            medicationID: dose.medicationID,
//            scheduledTime: dose.scheduledTime,
//            status: status
//        )
//
//        todayViewModel.loadTodayMedications(
//            from: MedicationDataStore.shared.medications
//        )
//        medicationCollectionView.reloadData()
//    }
    private func presentDoseAlert(for dose: TodayDoseItem) {

        let alert = UIAlertController(
            title: dose.medicationName,
            message: "Did you take the medicine?",
            preferredStyle: .alert
        )

        let takenAction = UIAlertAction(title: "Taken", style: .default) { [weak self] _ in
            self?.updateDose(dose, status: .taken)
        }

        let skippedAction = UIAlertAction(title: "Skipped", style: .destructive) { [weak self] _ in
            self?.updateDose(dose, status: .skipped)
        }

        let cancelAction = UIAlertAction(title: "✕ Cancel", style: .cancel)

        alert.addAction(takenAction)
        alert.addAction(skippedAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }


    private func setupCollectionView() {
        medicationCollectionView.dataSource = self
        medicationCollectionView.delegate = self
        medicationCollectionView.backgroundColor = .clear

        medicationCollectionView.register(
            UINib(nibName: "TodayMedicationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TodayMedicationCollectionViewCell"
        )

        medicationCollectionView.register(
            UINib(nibName: "MyMedicationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "MyMedicationCollectionViewCell"
        )
    }

    // MARK: - Segment Handling
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        currentSegment = sender.selectedSegmentIndex == 0 ? .today : .myMedication
        loadMedications()
        updateUIForSegment()
    }

    private func updateUIForSegment() {
        navigationItem.rightBarButtonItem =
            currentSegment == .myMedication
            ? UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(editTapped)
            )
            : nil
    }

    // MARK: - Actions
    @IBAction func plusButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "AddMedVC"
        ) as! AddMedicationViewController

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @objc private func editTapped() {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "EditMedicationViewController"
        ) as! EditMedicationViewController

        vc.medications = myMedications

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension MainMedicationViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        switch currentSegment {
        case .today:
            return todayViewModel.todayDoses.count
        case .myMedication:
            return myMedications.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        switch currentSegment {

        case .today:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TodayMedicationCollectionViewCell",
                for: indexPath
            ) as! TodayMedicationCollectionViewCell

            cell.configure(with: todayViewModel.todayDoses[indexPath.item])
            return cell

        case .myMedication:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MyMedicationCollectionViewCell",
                for: indexPath
            ) as! MyMedicationCollectionViewCell

            cell.configure(with: myMedications[indexPath.item])
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainMedicationViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 120)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        8
    }
}

// MARK: - UICollectionViewDelegate (Tap Handling)
extension MainMedicationViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard currentSegment == .today else { return }

        let dose = todayViewModel.todayDoses[indexPath.item]
        presentDoseAlert(for: dose)
    }

//    private func presentDosePopover(for dose: TodayDoseItem) {
//        let vc = DoseActionPopoverViewController()
//        vc.dose = dose
//
//        vc.onActionSelected = { [weak self] status in
//            self?.updateDose(dose, status: status)
//        }
//
//        if let sheet = vc.sheetPresentationController {
//            sheet.detents = [.medium()]
//            sheet.prefersGrabberVisible = true
//            sheet.preferredCornerRadius = 16
//        }
//
//        present(vc, animated: true)
//    }


}

// MARK: - Dose Action Sheet
extension MainMedicationViewController {

    private func presentDoseActionSheet(for dose: TodayDoseItem) {

        let alert = UIAlertController(
            title: dose.medicationName,
            message: "Did you take this medication?",
            preferredStyle: .actionSheet
        )

        let takenAction = UIAlertAction(title: "Taken", style: .default) { _ in
            self.updateDose(dose, status: .taken)
        }

        let skippedAction = UIAlertAction(title: "Skipped", style: .default) { _ in
            self.updateDose(dose, status: .skipped)
        }

        let cancelAction = UIAlertAction(title: "✕ Close", style: .cancel)

        alert.addAction(takenAction)
        alert.addAction(skippedAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
    private func updateDose(_ dose: TodayDoseItem, status: DoseLogStatus) {
        MedicationDataStore.shared.updateDoseStatus(
            medicationID: dose.medicationID,
            scheduledTime: dose.scheduledTime,
            status: status
        )

        loadMedications() // reloads data + reloads collection view
    }


//    private func updateDose(_ dose: TodayDoseItem, status: DoseLogStatus) {
//        MedicationDataStore.shared.updateDoseStatus(
//            medicationID: dose.medicationID,
//            scheduledTime: dose.scheduledTime,
//            status: status
//        )
//
//        loadMedications()
//    }
}
