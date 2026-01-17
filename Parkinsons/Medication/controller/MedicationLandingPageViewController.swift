//
//  MedicationLandingPageViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class MedicationLandingPageViewController: UIViewController,
                                           UICollectionViewDelegate,
                                           SkippedTakenDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    var todaysMedications: [MedicationDose] = []
    var allMedications: [Medication] = []
    var selectedDose: MedicationDose?
    var selectedMedication: Medication?
    private var medicationObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        loadMedications()
        medicationObserver = NotificationCenter.default.addObserver(
                forName: Notification.Name("MedicationUpdated"),
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadMedications()
            }
    }
    deinit {
        if let observer = medicationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func didUpdateDoseStatus(_ dose: MedicationDose, status: DoseStatus) {
        if let index = todaysMedications.firstIndex(where: { $0.id == dose.id }) {
            todaysMedications[index].status = status
        }

        if let medIndex = allMedications.firstIndex(where: { $0.id == dose.medicationID }),
           let doseIndex = allMedications[medIndex].doses.firstIndex(where: { $0.id == dose.id }) {
            allMedications[medIndex].doses[doseIndex].status = status
            MedicationDataStore.shared.updateMedication(allMedications[medIndex])
        }

        loadMedications()
    }

    private func dosePriority(_ dose: MedicationDose, now: Date) -> Int {
        if dose.status == .taken || dose.status == .skipped { return 2 }
        if dose.time > now { return 0 }
        return 1
    }

    private func isMedicationDueToday(_ med: Medication, date: Date = Date()) -> Bool {
        switch med.schedule {
        case .everyday: return true
        case .none: return false
        case .weekly(let days):
            let weekday = Calendar.current.component(.weekday, from: date)
            return days.contains(weekday)
        }
    }

    @objc func loadMedications() {
        allMedications = MedicationDataStore.shared.medications
        todaysMedications = []

        for med in allMedications {
            guard isMedicationDueToday(med) else { continue }
            let normalized = med.doses.map { normalizeDoseDate($0) }
            todaysMedications.append(contentsOf: normalized)
        }

        let now = Date()
        todaysMedications.sort { a, b in
            let pA = dosePriority(a, now: now)
            let pB = dosePriority(b, now: now)
            if pA != pB { return pA < pB }
            return a.time < b.time
        }

        collectionView.reloadData()
    }

    @IBAction func editMyMedications(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditMedicationViewController")
            as! EditMedicationViewController
        vc.medications = allMedications
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedDose = todaysMedications[indexPath.row]
            openSkipTakenModal(for: selectedDose!)
        } else {
            openEditMedicationScreen()
        }
    }

    func myMedicationSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(100)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(300)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 20, trailing: 15)

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(30)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
        section.boundarySupplementaryItems = [header]
        return section
    }

    func todaySection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(80)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(300)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 20, trailing: 15)

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(30)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)
        section.boundarySupplementaryItems = [header]

        return section
    }

    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, env in
            return sectionIndex == 0 ? self.todaySection() : self.myMedicationSection()
        }
    }

    func configureCollectionView() {
        collectionView.register(
            UINib(nibName: "HeaderViewCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderViewCollectionReusableView"
        )

        collectionView.register(
            UINib(nibName: "TodayMedicationCell", bundle: nil),
            forCellWithReuseIdentifier: "TodayMedicationCell"
        )

        collectionView.register(
            UINib(nibName: "MyMedicationCell", bundle: nil),
            forCellWithReuseIdentifier: "MyMedicationCell"
        )

        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func openEditMedicationScreen() {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "EditMedicationViewController"
        ) as! EditMedicationViewController

        vc.medications = allMedications
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    func openSkipTakenModal(for dose: MedicationDose) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "SkippedTakenViewController"
        ) as! SkippedTakenViewController

        vc.selectedDose = dose

        if let med = allMedications.first(where: { $0.id == dose.medicationID }) {
            vc.receivedTitle = med.name
            vc.receivedSubtitle = med.form
            vc.receivedIconName = med.iconName
        }

        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func normalizeDoseDate(_ dose: MedicationDose) -> MedicationDose {
        var updatedDose = dose
        let calendar = Calendar.current

        if !calendar.isDateInToday(dose.time) {
            let components = calendar.dateComponents([.hour, .minute], from: dose.time)
            let today = calendar.date(
                bySettingHour: components.hour ?? 0,
                minute: components.minute ?? 0,
                second: 0,
                of: Date()
            )!
            updatedDose.time = today
            updatedDose.status = .none
        }

        return updatedDose
    }
    
    @IBAction func plusButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "AddMedVC"
        ) as! AddMedicationViewController
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}

extension MedicationLandingPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "HeaderViewCollectionReusableView",
            for: indexPath
        ) as! HeaderViewCollectionReusableView

        if indexPath.section == 0 {
            header.configureHeader(text: "Today's Medication", showEdit: false)
        } else {
            header.configureHeader(text: "My Medications", showEdit: true)
            header.editButton.addTarget(self,
                                        action: #selector(editMyMedications),
                                        for: .touchUpInside)
        }
        return header
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? todaysMedications.count : allMedications.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TodayMedicationCell",
                for: indexPath
            ) as! TodayMedicationCell

            let dose = todaysMedications[indexPath.item]
            if let med = allMedications.first(where: { $0.id == dose.medicationID }) {
                cell.configure(with: dose, medication: med)
            }

            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MyMedicationCell",
            for: indexPath
        ) as! MyMedicationCell

        cell.configure(with: allMedications[indexPath.item])
        return cell
    }
}
