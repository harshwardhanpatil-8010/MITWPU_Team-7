import UIKit
import Foundation

final class MainMedicationViewController: UIViewController {

    @IBOutlet weak var medSegment: UISegmentedControl!
    @IBOutlet weak var medicationCollectionView: UICollectionView!
    @IBOutlet weak var noMedicationLabel: UIStackView!
    
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    enum SegmentType {
        case today
        case myMedication
    }

    private var isShowingAllUpcoming = false
    private var displayedUpcomingDoses: [TodayDoseItem] {
        if isShowingAllUpcoming {
            return upcomingDoses
        } else {
            return Array(upcomingDoses.prefix(3))
        }
    }

    private var dueDoses: [TodayDoseItem] {
        todayViewModel.todayDoses.filter { $0.isDue }
    }

    private var upcomingDoses: [TodayDoseItem] {
        todayViewModel.todayDoses.filter { !$0.isDue }
    }

    private var loggedDoses: [LoggedDoseItem] = []
    private var isEditingLogged = false
    private let todayViewModel = TodayMedicationViewModel()
    private var currentSegment: SegmentType = .today
    private var myMedications: [Medication] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadMedications()
        updateUIForSegment()
        self.definesPresentationContext = true
        if let layout = medicationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = .zero
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

    }
    @objc private func appDidBecomeActive() {
        loadMedications()
    }

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
        
        medicationCollectionView.register(
            UINib(nibName: "LoggedEmptyFooterView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "LoggedEmptyFooterView"
        )

    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        currentSegment = sender.selectedSegmentIndex == 0 ? .today : .myMedication
        loadMedications()
        updateUIForSegment()
    }

    @objc private func medicationUpdated() {
        loadMedications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        editButton.isHidden = (currentSegment != .myMedication)
    }

    
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "EditMedicationViewController"
        ) as! EditMedicationViewController

        vc.medications = myMedications
        vc.delegate = self  

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    
    

    @IBAction func plusButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "AddMedVC"
        ) as! AddMedicationViewController
        
        vc.delegate = self
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

   
}

extension MainMedicationViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "MedicationSectionHeaderView",
                for: indexPath
            ) as! MedicationSectionHeaderView

            if indexPath.section == 0 {
                header.configure(
                    title: "Today Medications",
                    actionTitle: nil,
                    action: nil
                )
            } else {
                header.configure(
                    title: "Logged",
                    actionTitle: "Edit",
                    action: .edit
                )
            }

            header.delegate = self
            return header
        }

        if kind == UICollectionView.elementKindSectionFooter,
           currentSegment == .today,
           indexPath.section == 1,
           loggedDoses.isEmpty {

            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "LoggedEmptyFooterView",
                for: indexPath
            )
            return footer
        }

        return UICollectionReusableView()
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
                ? dueDoses.count + displayedUpcomingDoses.count
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

                let item: TodayDoseItem

                if indexPath.item < dueDoses.count {
                    item = dueDoses[indexPath.item]
                } else {
                    item = displayedUpcomingDoses[indexPath.item - dueDoses.count]
                }

                cell.configure(with: item)

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

extension MainMedicationViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if currentSegment == .myMedication {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        if currentSegment == .today && section == 1 {
            return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        }

        return .zero
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {

        guard currentSegment == .today else { return .zero }

        if section == 1 && loggedDoses.isEmpty {
            return CGSize(width: collectionView.bounds.width, height: 80)
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
                return CGSize(width: collectionView.bounds.width, height: 120)
            } else {
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
        if currentSegment == .myMedication {
            return -15
        }

        if currentSegment == .today && section == 1 {
            return -7
        }
        return -7
    }
}

extension MainMedicationViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard currentSegment == .today else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 36)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard currentSegment == .today else { return }
        guard indexPath.section == 0 else { return }

        let dose: TodayDoseItem
        if indexPath.item < dueDoses.count {
            dose = dueDoses[indexPath.item]
        } else {
            dose = displayedUpcomingDoses[indexPath.item - dueDoses.count]
        }

        presentDoseAlert(for: dose)
    }

}

extension MainMedicationViewController {

    private func updateDose(_ dose: TodayDoseItem, status: DoseLogStatus) {
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
        loadMedications()
    }
}

extension MainMedicationViewController: MedicationSectionHeaderViewDelegate {

    func didTapShowAllToday() {
        isShowingAllUpcoming.toggle()

        medicationCollectionView.performBatchUpdates {
            medicationCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }

    func didTapEditLoggedSection() {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "EditLogViewController"
        ) as! EditLogViewController

        vc.loggedDoses = loggedDoses
        vc.delegate = self

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

}

extension MainMedicationViewController: AddMedicationDelegate {
    func didUpdateMedication() {
        loadMedications()
    }
}
extension MainMedicationViewController: EditLogDelegate {

    func didUpdateLoggedDoses(_ updated: [LoggedDoseItem]) {
        self.loggedDoses = updated
        medicationCollectionView.reloadSections(IndexSet(integer: 1)) // Logged section
    }
}

