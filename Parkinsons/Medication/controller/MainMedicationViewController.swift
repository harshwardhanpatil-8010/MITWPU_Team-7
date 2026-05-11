import UIKit
import Foundation
import CoreData

final class MainMedicationViewController: UIViewController {

    @IBOutlet weak var medSegment: UISegmentedControl!
    @IBOutlet weak var medicationCollectionView: UICollectionView!
    @IBOutlet weak var medicationCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noMedicationLabel: UIStackView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var isPresentedFromProfile: Bool = false
    @IBOutlet weak var plusButton: UIButton!

    enum SegmentType {
        case today
        case myMedication
    }
    
    private var allMedicationsLoggedToday: Bool {
        dueDoses.isEmpty && upcomingDoses.isEmpty && !loggedDoses.isEmpty
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
    
    private var didBecomeActiveObserver: NSObjectProtocol?
    private var doseLoggedObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        if isPresentedFromProfile {
                    setupProfilePresentationUI()
                }
        
        setupCollectionView()
        updateUIForSegment()
        self.definesPresentationContext = true
        
        if let layout = medicationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.headerReferenceSize = .zero
        }
        didBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadMedications()
        }
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("MedicationLogged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.loadMedications()
        }

        
        let scrollAppearance = UINavigationBarAppearance()
        scrollAppearance.configureWithTransparentBackground()
        scrollAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
            .foregroundColor: UIColor.label
        ]

        let screenWidth = UIScreen.main.bounds.width
        scrollAppearance.titlePositionAdjustment = UIOffset(horizontal: -(screenWidth / 2) + 110, vertical: 0)

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        standardAppearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        navigationController?.navigationBar.standardAppearance = standardAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = scrollAppearance

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeight()
    }
    private func setupProfilePresentationUI() {
       
            let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissModal))
            self.navigationItem.leftBarButtonItem = closeButton
            

            plusButton.isHidden = true
            

            medSegment.selectedSegmentIndex = 1
            currentSegment = .myMedication
        }
    @objc private func dismissModal() {
            self.dismiss(animated: true, completion: nil)
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMedications()
    }

    deinit {
        if let observer = didBecomeActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = doseLoggedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("MedicationLogged"), object: nil)
    }
    
    private func loadMedications() {
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        do {
            myMedications = try PersistenceController.shared.viewContext.fetch(request)
        } catch {
            print("Failed to fetch medications:", error)
        }

        if currentSegment == .today {
            todayViewModel.loadTodayMedications(from: myMedications)
            let logRequest: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            logRequest.predicate = NSPredicate(
                format: "doseDay >= %@ AND doseDay < %@",
                startOfDay as NSDate,
                endOfDay as NSDate
            )

            let logs = (try? PersistenceController.shared.viewContext.fetch(logRequest)) ?? []

            todayViewModel.loadLoggedDoses(medications: myMedications, logs: logs, for: Date())
            loggedDoses = todayViewModel.loggedDoses
        }

        medicationCollectionView.reloadData()
        medicationCollectionView.layoutIfNeeded()
        updateCollectionViewHeight()
        updateNoMedicationState()
        updateUIForSegment()
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
        medicationCollectionView.alwaysBounceVertical = false
        medicationCollectionView.isScrollEnabled = false

        medicationCollectionView.register(UINib(nibName: "TodayMedicationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TodayMedicationCollectionViewCell")
        medicationCollectionView.register(UINib(nibName: "MyMedicationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyMedicationCollectionViewCell")
        medicationCollectionView.register(UINib(nibName: "LoggedMedicationCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LoggedMedicationCollectionViewCell")
        medicationCollectionView.register(UINib(nibName: "MedicationSectionHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MedicationSectionHeaderView")
        medicationCollectionView.register(UINib(nibName: "LoggedEmptyFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LoggedEmptyFooterView")
    }

    private func updateCollectionViewHeight() {
        let contentHeight = medicationCollectionView.collectionViewLayout.collectionViewContentSize.height
        guard contentHeight > 0 else { return }
        medicationCollectionViewHeightConstraint.constant = contentHeight
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        currentSegment = sender.selectedSegmentIndex == 0 ? .today : .myMedication
        loadMedications()
        updateUIForSegment()
    }

    private func updateLoggedStatus(_ item: LoggedDoseItem, status: DoseStatus) {
        let context = PersistenceController.shared.viewContext

        let logRequest: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
        logRequest.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)

        if let log = (try? context.fetch(logRequest))?.first {
            log.doseLogStatus = status.rawValue
            log.dose?.doseStatus = status.rawValue
        }

        PersistenceController.shared.save(context)
        loadMedications()
    }


    private func updateUIForSegment() {
        if currentSegment == .myMedication {
            editButton.isHidden = false
            editButton.isEnabled = !myMedications.isEmpty
        } else {
            editButton.isHidden = true
        }
    }


    @IBAction func editButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditMedicationViewController") as! EditMedicationViewController
        vc.medications = myMedications
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @IBAction func plusButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddMedVC") as! AddMedicationViewController
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}

extension MainMedicationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MedicationSectionHeaderView", for: indexPath) as! MedicationSectionHeaderView
            if indexPath.section == 0 {
                let hasMoreThanThreeUpcoming = upcomingDoses.count > 3

                header.configure(
                    title: "Upcoming",
                    actionTitle: hasMoreThanThreeUpcoming
                        ? (isShowingAllUpcoming ? "Show Less" : "Show All")
                        : nil,
                    action: hasMoreThanThreeUpcoming ? .showAll : nil,
                    isExpanded: isShowingAllUpcoming
                )
            }
            else {
                let isEditEnabled = !loggedDoses.isEmpty

                header.configure(
                    title: "Logged",
                    actionTitle: "Edit",
                    action: .edit,
                    isActionEnabled: isEditEnabled
                )

            }
            header.delegate = self
            return header
        }

        if kind == UICollectionView.elementKindSectionFooter, currentSegment == .today {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoggedEmptyFooterView", for: indexPath) as! LoggedEmptyFooterView
            if indexPath.section == 1 && loggedDoses.isEmpty {
                footer.configure(message: "No medications logged yet.")
                return footer
            }
            if indexPath.section == 0 && allMedicationsLoggedToday {
                footer.configure(message: "All medications logged for today.")
                return footer
            }
        }
        return UICollectionReusableView()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentSegment == .today ? 2 : 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentSegment == .today {
            return section == 0 ? dueDoses.count + displayedUpcomingDoses.count : loggedDoses.count
        }
        return myMedications.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentSegment == .today {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodayMedicationCollectionViewCell", for: indexPath) as! TodayMedicationCollectionViewCell
                let item = indexPath.item < dueDoses.count ? dueDoses[indexPath.item] : displayedUpcomingDoses[indexPath.item - dueDoses.count]
                cell.configure(with: item)
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoggedMedicationCollectionViewCell", for: indexPath) as! LoggedMedicationCollectionViewCell
            cell.configure(with: loggedDoses[indexPath.item])
            cell.setEditing(isEditingLogged)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyMedicationCollectionViewCell", for: indexPath) as! MyMedicationCollectionViewCell
        cell.configure(with: myMedications[indexPath.item])
        return cell
    }
}

extension MainMedicationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard currentSegment == .today else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 36)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard currentSegment == .today else { return .zero }
        if (section == 1 && loggedDoses.isEmpty) || (section == 0 && allMedicationsLoggedToday) {
            return CGSize(width: collectionView.bounds.width, height: 80)
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

            return UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalPadding: CGFloat = 40
        _ = collectionView.bounds.width - horizontalPadding
        let height: CGFloat =  80
        return CGSize(width: collectionView.bounds.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return (currentSegment == .myMedication) ? 0 : 0
    }
}

extension MainMedicationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard currentSegment == .today, indexPath.section == 0 else { return }
        let dose = indexPath.item < dueDoses.count ? dueDoses[indexPath.item] : displayedUpcomingDoses[indexPath.item - dueDoses.count]
        presentDoseAlert(for: dose)
    }
}

extension MainMedicationViewController {
   
        private func updateDose(_ dose: TodayDoseItem, status: DoseStatus) {

            MedicationDoseLogger.shared.log(
                dose: dose,
                status: status,
                medications: myMedications,
                context: PersistenceController.shared.viewContext
            )

            if status == .skipped,
               let med = myMedications.first(where: { $0.id == dose.medicationID }) {
                let iso = ISO8601DateFormatter()
                let userInfo: [AnyHashable: Any] = [
                    MedNotifKey.doseID:        dose.id.uuidString,
                    MedNotifKey.medID:         dose.medicationID.uuidString,
                    MedNotifKey.medName:       med.medicationName ?? "Medication",
                    MedNotifKey.medForm:       med.medicationForm ?? "",
                    MedNotifKey.medStrength:   Int(med.medicationStrength),
                    MedNotifKey.medUnit:       med.medicationUnit ?? "",
                    MedNotifKey.iconName:      med.medicationIconName ?? "tablet1",
                    MedNotifKey.scheduledTime: iso.string(from: dose.scheduledTime)
                ]
                if let payload = MedicationAlarmPayload(userInfo: userInfo) {
                    MedicationNotificationManager.shared.cancelOnTimeNotification(forDoseID: dose.id)
                    MedicationNotificationManager.shared.scheduleSkipFollowUp(payload: payload)
                }
            } else {

                MedicationNotificationManager.shared.cancelNotifications(forDoseID: dose.id)
            }

            loadMedications()

            NotificationCenter.default.post(
                name: NSNotification.Name("MedicationLogged"),
                object: nil
            )
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
        let vc = storyboard.instantiateViewController(withIdentifier: "EditLogViewController") as! EditLogViewController
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
        NotificationCenter.default.post(name: NSNotification.Name("MedicationLogged"), object: nil)
    }
}

extension MainMedicationViewController: EditLogDelegate {
    func didUpdateLoggedDoses(_ updated: [LoggedDoseItem]) {
        let context = PersistenceController.shared.viewContext

        for item in updated {
            let logRequest: NSFetchRequest<MedicationDoseLog> = MedicationDoseLog.fetchRequest()
            logRequest.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)

            if let log = (try? context.fetch(logRequest))?.first {
                log.doseLogStatus = item.status.rawValue
                if let coreDose = log.dose {
                    coreDose.doseStatus = item.status.rawValue

                    
                    if item.status != .none, let doseID = coreDose.id {
                        MedicationNotificationManager.shared.cancelNotifications(forDoseID: doseID)
                    }
                }
            }
        }

        PersistenceController.shared.save(context)
        NotificationCenter.default.post(name: NSNotification.Name("MedicationLogged"), object: nil)
        loadMedications()
    }
}
