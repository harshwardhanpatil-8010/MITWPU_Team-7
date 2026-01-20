//
//  EditMedicationViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class EditMedicationViewController: UIViewController,
                                    UICollectionViewDelegate,
                                    AddMedicationDelegate {

    var medications: [Medication] = []

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: AddMedicationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            UINib(nibName: "EditMedicationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "EditMedCell"
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadMedications()
    }

    private func reloadMedications() {
        medications = MedicationDataStore.shared.medications
        collectionView.reloadData()
    }


    func didUpdateMedication() {
        reloadMedications()
        delegate?.didUpdateMedication()
    }

    @IBAction func backTapped(_ sender: Any) {
        delegate?.didUpdateMedication()
        dismiss(animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = medications[indexPath.row]

        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddMedVC")
            as! AddMedicationViewController

        vc.isEditMode = true
        vc.medicationToEdit = selected
        vc.delegate = self

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}

extension EditMedicationViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return medications.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EditMedCell",
            for: indexPath
        ) as! EditMedicationCollectionViewCell

        cell.configure(with: medications[indexPath.row])
        return cell
    }
}

extension EditMedicationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: collectionView.bounds.width,
            height: 80
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return -7
    }
}

