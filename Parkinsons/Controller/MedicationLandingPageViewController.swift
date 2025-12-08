//
//  MedicationLandingPageViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class MedicationLandingPageViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    var todaysMedications: [MedicationDose] = []
    var allMedications: [Medication] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        loadSampleData()
        // Do any additional setup after loading the view.
        
    }
    
    @objc func editMyMedications() {
            print("Edit button tapped for My Medications!")
            // open edit screen here
        }
    
    func loadSampleData() {

        // First create medications
        var levodopa = Medication(
            id: UUID(),
            name: "Levodopa",
            form: "Capsule",
            iconName: "capsule",
            schedule: "Everyday",
            doses: []
            
        )

        var carbidopa = Medication(
            id: UUID(),
            name: "Carbidopa",
            form: "Tablet",
            iconName: "tablet",
            schedule: "Mon, Wed",
            doses: []
        )

        // Now create doses with medication included
        let dose1 = MedicationDose(
            id: UUID(),
            time: Date(),
            status: .none,
            medication: levodopa
        )

        let dose2 = MedicationDose(
            id: UUID(),
            time: Date().addingTimeInterval(3600),
            status: .none,
            medication: carbidopa
        )

        levodopa.doses = [dose1]
        carbidopa.doses = [dose2]

        todaysMedications = [dose1, dose2]

        allMedications = [levodopa, carbidopa]
    }


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
            cell.configure(with: dose)
            return cell

        } else {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "MyMedicationCell",
                for: indexPath
            ) as! MyMedicationCell

            let medication = allMedications[indexPath.item]
            cell.configure(with: medication)
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


