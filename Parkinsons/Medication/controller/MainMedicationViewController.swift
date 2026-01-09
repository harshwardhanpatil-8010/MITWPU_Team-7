//
//  MainMedicationViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class MainMedicationViewController: UIViewController{

    @IBOutlet weak var medSegment: UISegmentedControl!
    @IBOutlet weak var medicationCollectionView: UICollectionView!
    enum SegmentType {
            case today
            case myMedication
        }
    private var currentSegment: SegmentType = .today
    private var myMedications: [Medication] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
            myMedications = MedicationDataStore.shared.medications

            updateUIForSegment()
        loadMedications()
        // Do any additional setup after loading the view.
    }
    private func updateUIForSegment() {

        switch currentSegment {

        case .today:
            navigationItem.rightBarButtonItem = nil   // No Edit button
            medicationCollectionView.reloadData()      // Will be empty

        case .myMedication:
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(editTapped)
            )
            medicationCollectionView.reloadData()
        }
    }
    @objc private func editTapped() {
        print("Edit My Medication tapped")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch currentSegment {
        case .today:
            return 0   // 👈 EMPTY for now
        case .myMedication:
            return myMedications.count
        }
    }


    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
                currentSegment = .today
            } else {
                currentSegment = .myMedication
            }

            updateUIForSegment()
    }
    private func setupCollectionView() {
        medicationCollectionView.dataSource = self
//        medicationCollectionView.delegate = self

        medicationCollectionView.register(
                UINib(nibName: "MyMedicationCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "MyMedicationCollectionViewCell"
            )

        medicationCollectionView.backgroundColor = .clear
        }

        // MARK: - Data
        private func loadMedications() {
            myMedications = MedicationDataStore.shared.medications
            medicationCollectionView.reloadData()
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
extension MainMedicationViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myMedications.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MyMedicationCollectionViewCell",
            for: indexPath
        ) as? MyMedicationCollectionViewCell else {
            return UICollectionViewCell()
        }

        let medication = myMedications[indexPath.item]
        cell.configure(with: medication)
        return cell
    }
}
//extension MainMedicationViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAt indexPath: IndexPath
//    ) -> CGSize {
//
//        return CGSize(
//            width: collectionView.bounds.width,
//            height: 120
//        )
//    }
//
//    func collectionView(
//        _ collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        minimumLineSpacingForSectionAt section: Int
//    ) -> CGFloat {
//        return 16
//    }
//}
