//
//  MedicationLandingPageViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class MedicationLandingPageViewController: UIViewController, UICollectionViewDelegate, SkippedTakenDelegate {
    var selectedMedication: Medication?

    func didUpdateDoseStatus(_ dose: MedicationDose, status: DoseStatus) {
        // 1. Update in todaysMedications (UI array)
        if let index = todaysMedications.firstIndex(where: { $0.id == dose.id }) {
            todaysMedications[index].status = status
        }

        // 2. Update in allMedications (source of truth)
        if let medIndex = allMedications.firstIndex(where: { $0.id == dose.medicationID }) {
            if let doseIndex = allMedications[medIndex].doses.firstIndex(where: { $0.id == dose.id }) {
                allMedications[medIndex].doses[doseIndex].status = status

                // 3. Persist the changed medication back to data store
                MedicationDataStore.shared.updateMedication(allMedications[medIndex])
            }
        }

        // 4. Rebuild & resort the list from stored/allMedications to ensure consistent ordering
        loadMedications()
    }

    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var todaysMedications: [MedicationDose] = []
    var allMedications: [Medication] = []
    var selectedDose: MedicationDose?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        loadMedications()
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(loadMedications),
                name: Notification.Name("MedicationUpdated"),
                object: nil)
//        medications = MedicationStorage.shared.fetchMedications()
//        loadSampleData()
        // Do any additional setup after loading the view.
        
    }
    
    private func dosePriority(_ dose: MedicationDose, now: Date) -> Int {

        if dose.status == .taken || dose.status == .skipped {
            return 2       // completed (bottom)
        }

        if dose.time > now {
            return 0       // upcoming (top)
        }

        return 1           // due (middle)
    }


    
    
    // MARK: - Helpers inside MedicationLandingPageViewController

    // Convert RepeatRule -> whether the med should appear today
    private func isMedicationDueToday(_ med: Medication, date: Date = Date()) -> Bool {
        switch med.schedule {
        case .everyday:
            return true
        case .none:
            return false
        case .weekly(let days):
            let weekday = Calendar.current.component(.weekday, from: date) // 1..7 Sun..Sat
            return days.contains(weekday)
        }
    }

    // Load saved meds from your MedicationDataStore and populate all/today arrays
    @objc func loadMedications() {
        allMedications = MedicationDataStore.shared.medications

        todaysMedications = []

        for med in allMedications {
            guard isMedicationDueToday(med) else { continue }
            todaysMedications.append(contentsOf: med.doses)
        }

        let now = Date()

        todaysMedications.sort { a, b in

            // 1️⃣ GROUP ORDER
            let priorityA = dosePriority(a, now: now)
            let priorityB = dosePriority(b, now: now)

            if priorityA != priorityB {
                return priorityA < priorityB
            }

            // 2️⃣ SAME GROUP → sort by time
            return a.time < b.time
        }

        collectionView.reloadData()
        

    }

    
    @objc func editMyMedications() {
        // Choose the medication currently selected OR open a list screen, whichever you prefer.
        if let first = allMedications.first {
            openEditMedicationScreen(for: first)
        }
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showEditMedication" {
//            let nav = segue.destination as! UINavigationController
//            let vc = nav.topViewController as! EditMedicationViewController
//
//            if let med = selectedMedication {
//                vc.medication = med
//            }
//        }
//
//        if segue.identifier == "showSkipper" {
//            let nav = segue.destination as! UINavigationController
//            let vc = nav.topViewController as! SkippedTakenViewController   // because it is embedded
//            
//            if let dose = selectedDose,
//               let med = allMedications.first(where: { $0.id == dose.medicationID }) {
//                vc.selectedDose = dose
//                vc.receivedTitle = med.name
//                vc.receivedSubtitle = med.form
//                vc.receivedIconName = med.iconName
//                vc.delegate = self
//            }
//
//            
//            vc.delegate = self
//        }
//    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            // Today’s medications → open skip/taken modal
            selectedDose = todaysMedications[indexPath.row]
            openSkipTakenModal(for: selectedDose!)
        } else {
            // My medications → open edit screen
            selectedMedication = allMedications[indexPath.row]
            openEditMedicationScreen(for: selectedMedication!)
        }
    }


//    func openSkipTakenModal(for dose: MedicationDose) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//        let vc = storyboard.instantiateViewController(withIdentifier: "SkippedTakenViewController") as! SkippedTakenViewController
//
//        // Pass the data
//        vc.selectedDose = dose
//
//        vc.modalPresentationStyle = .overCurrentContext
//        present(vc, animated: true)
//    }


//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showSkipper" {
//            let nav = segue.destination as! UINavigationController
//            let vc = nav.topViewController as! SkippedTakenViewController   // because it is embedded
//            
//            vc.selectedDose = selectedDose
//            vc.receivedTitle = selectedDose?.medication.name
//            vc.receivedSubtitle = selectedDose?.medication.form
//            vc.receivedIconName = selectedDose?.medication.iconName
//            
//            vc.delegate = self
//        }
//    }




    
//    func loadSampleData() {
//
//        // Create medications
//        var levodopa = Medication(
//            id: UUID(),
//            name: "Levodopa",
//            form: "Capsule",
//            iconName: "capsule",
//            schedule: "Everyday",
//            doses: []
//        )
//
//        var carbidopa = Medication(
//            id: UUID(),
//            name: "Carbidopa",
//            form: "Tablet",
//            iconName: "tablet",
//            schedule: "Mon, Wed",
//            doses: []
//        )
//
//        let now = Date()
//
//        // Dose time 1 hour **in the past**
//        let pastTime = now.addingTimeInterval(-3600)
//
//        // Dose time 1 hour **in the future**
//        let futureTime = now.addingTimeInterval(3600)
//
//        let dose1 = MedicationDose(
//            id: UUID(),
//            time: pastTime,
//            status: .none,
//            medication: levodopa
//        )
//
//        let dose2 = MedicationDose(
//            id: UUID(),
//            time: futureTime,
//            status: .none,
//            medication: carbidopa
//        )
//
//        levodopa.doses = [dose1]
//        carbidopa.doses = [dose2]
//
//        todaysMedications = [dose1, dose2]
//        allMedications = [levodopa, carbidopa]
//    }


    func myMedicationSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 20, trailing: 15)

        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(40)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]


        return section
    }

    
    func todaySection() -> NSCollectionLayoutSection {
        


        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 20, trailing: 15)
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(40)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]

        return section
    }

    
    func createLayout() -> UICollectionViewLayout {

            let layout = UICollectionViewCompositionalLayout { sectionIndex, env in

                if sectionIndex == 0 {
                    return self.todaySection()
                } else {
                    return self.myMedicationSection()
                }
            }

            return layout
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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

            header.editButton.addTarget(
                self,
                action: #selector(editMyMedications),
                for: .touchUpInside
            )
        }

        return header
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

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

            // Find parent medication for this dose
            if let med = allMedications.first(where: { $0.id == dose.medicationID }) {
                cell.configure(with: dose, medication: med) // note the new signature
            } else {
                // fallback: configure with dose only (you can add a fallback configure overload)
                // or just clear the cell
            }

            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MyMedicationCell",
                for: indexPath
            ) as! MyMedicationCell

            let medication = allMedications[indexPath.item]
            cell.configure(with: medication) // keep as-is
            return cell
        }
    }

}

//extension MedicationLandingPageViewController {
//
//    // MARK: - Open Add Medication Screen
//    @objc func openAddMedication() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(
//            withIdentifier: "AddMedicationViewController"
//        ) as! AddMedicationViewController
//
//        vc.modalPresentationStyle = .pageSheet
//        present(vc, animated: true)
//    }
//
//    // MARK: - Open Edit Medication Screen
//    func openEditMedication(for medication: Medication) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(
//            withIdentifier: "EditMedicationViewController"
//        ) as! EditMedicationViewController
//
//        vc.medication = medication     // pass data
//        vc.modalPresentationStyle = .pageSheet
//        present(vc, animated: true)
//    }
//}


// MARK: - Navigation (Programmatic)
extension MedicationLandingPageViewController {

    func openEditMedicationScreen(for medication: Medication) {
        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "EditMedicationViewController"
        ) as! EditMedicationViewController
        
        vc.medication = medication   // pass object
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
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true)
    }
}
