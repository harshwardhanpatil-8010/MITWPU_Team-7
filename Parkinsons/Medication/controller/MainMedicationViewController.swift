import UIKit
import Foundation

final class MainMedicationViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var medSegment: UISegmentedControl!
    @IBOutlet weak var medicationCollectionView: UICollectionView!
    
    @IBOutlet weak var noMedicationLabel: UIStackView!
    
    // MARK: - Segment Type
    enum SegmentType {
        case today
        case myMedication
    }
    private var loggedDoses: [LoggedDoseItem] = []
    private var isEditingLogged = false


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
        if let layout = medicationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = .zero
        }
        
        
        

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMedications()
    }

    // MARK: - Data
    private func updateNoMedicationState() {
        let shouldShowLabel: Bool

        if currentSegment == .today {
            let hasUpcoming = !todayViewModel.todayDoses.isEmpty
            let hasLogged = !loggedDoses.isEmpty
            shouldShowLabel = !(hasUpcoming || hasLogged)
        } else {
            shouldShowLabel = myMedications.isEmpty
        }

        noMedicationLabel.isHidden = !shouldShowLabel
        medicationCollectionView.isHidden = shouldShowLabel
    }

    private func loadMedications() {
        myMedications = MedicationDataStore.shared.medications

        if currentSegment == .today {
            todayViewModel.loadTodayMedications(from: myMedications)

            todayViewModel.loadLoggedDoses(
                medications: myMedications,
                logs: DoseLogDataStore.shared.logs,
                for: Date()
            )

            loggedDoses = todayViewModel.loggedDoses


        }

        medicationCollectionView.reloadData()
        updateNoMedicationState()
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

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

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
        
        medicationCollectionView.register(
            UINib(nibName: "LoggedMedicationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "LoggedMedicationCollectionViewCell"
        )
        
        medicationCollectionView.register(
            UINib(
                nibName: "MedicationSectionHeaderView",
                bundle: nil
            ),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "MedicationSectionHeaderView"
        )



    }

    // MARK: - Segment Handling
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        currentSegment = sender.selectedSegmentIndex == 0 ? .today : .myMedication
        loadMedications()
        updateUIForSegment()
    }
    private func updateLoggedStatus(_ item: LoggedDoseItem, status: DoseLogStatus) {
        DoseLogDataStore.shared.updateLogStatus(
            logID: item.id,
            status: DoseStatus(from: status)
        )
        loadMedications()
    }

    private func presentEditStatusSheet(for item: LoggedDoseItem) {

        let alert = UIAlertController(
            title: item.medicationName,
            message: "Update status",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Taken", style: .default) { _ in
            self.updateLoggedStatus(item, status: .taken)
        })

        alert.addAction(UIAlertAction(title: "Skipped", style: .destructive) { _ in
            self.updateLoggedStatus(item, status: .skipped)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
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
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "MedicationSectionHeaderView",
            for: indexPath
        ) as! MedicationSectionHeaderView

        if currentSegment == .today {
            if indexPath.section == 0 {
                header.configure(title: "Upcoming Medications", showEdit: false)
            } else {
                header.configure(title: "Logged", showEdit: true)
                header.delegate = self
            }
        }


        return header
    }


    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentSegment == .today ? 2 : 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        if currentSegment == .today {
            return section == 0
                ? todayViewModel.todayDoses.count
                : loggedDoses.count
        }

        return myMedications.count
    }


    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if currentSegment == .today {

            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "TodayMedicationCollectionViewCell",
                    for: indexPath
                ) as! TodayMedicationCollectionViewCell

                cell.configure(with: todayViewModel.todayDoses[indexPath.item])
                return cell
            }

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "LoggedMedicationCollectionViewCell",
                for: indexPath
            ) as! LoggedMedicationCollectionViewCell

            cell.configure(with: loggedDoses[indexPath.item])
            cell.setEditing(isEditingLogged)
            return cell

        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MyMedicationCollectionViewCell",
            for: indexPath
        ) as! MyMedicationCollectionViewCell

        cell.configure(with: myMedications[indexPath.item])
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainMedicationViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {

        if currentSegment == .today && section == 1 {
            return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        }

        return .zero
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        if currentSegment == .today {
            if indexPath.section == 0 {
                // Upcoming
                return CGSize(width: collectionView.bounds.width, height: 120)
            } else {
                // Logged
                return CGSize(width: collectionView.bounds.width, height: 80)
            }
        }

        return CGSize(width: collectionView.bounds.width, height: 120)
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {

        if currentSegment == .today && section == 1 {
            return -7
        }
        return 8
    }

}

// MARK: - UICollectionViewDelegate (Tap Handling)
extension MainMedicationViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard currentSegment == .today else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 36)
    }

//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        referenceSizeForHeaderInSection section: Int
//    ) -> CGSize {
//
//        guard currentSegment == .today else { return .zero }
//
//        return CGSize(width: collectionView.bounds.width, height: 44)
//    }

    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard currentSegment == .today else { return }

        // ✅ Only upcoming meds are tappable
        guard indexPath.section == 0 else { return }

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

//    private func presentDoseActionSheet(for dose: TodayDoseItem) {
//
//        let alert = UIAlertController(
//            title: dose.medicationName,
//            message: "Did you take this medication?",
//            preferredStyle: .actionSheet
//        )
//
//        let takenAction = UIAlertAction(title: "Taken", style: .default) { _ in
//            self.updateDose(dose, status: .taken)
//        }
//
//        let skippedAction = UIAlertAction(title: "Skipped", style: .default) { _ in
//            self.updateDose(dose, status: .skipped)
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//
//        alert.addAction(takenAction)
//        alert.addAction(skippedAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true)
//    }
    private func updateDose(_ dose: TodayDoseItem, status: DoseLogStatus) {

        // 1. Save log
        let log = DoseLog(
            id: UUID(),
            medicationID: dose.medicationID,
            doseID: dose.id,
            scheduledTime: dose.scheduledTime,
            loggedAt: Date(),
            status: DoseStatus(from: status),
            day: Date().startOfDay
        )

        DoseLogDataStore.shared.logDose(log)

        // 2. Reload everything
        loadMedications()
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
extension MainMedicationViewController: MedicationSectionHeaderViewDelegate {

    func didTapEditLoggedSection() {
        isEditingLogged.toggle()
        medicationCollectionView.reloadSections(IndexSet(integer: 1))
    }
}
