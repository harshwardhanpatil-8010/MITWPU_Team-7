//
//  EditMedicationViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

// MARK: - Edit Medication Screen
class EditMedicationViewController: UIViewController,
                                    UICollectionViewDelegate,
                                    AddMedicationDelegate {

    // ---------------------------------------------------------
    // MARK: - Properties
    // ---------------------------------------------------------
    var medications: [Medication] = []
    weak var delegate: AddMedicationDelegate?

    // ---------------------------------------------------------
    // MARK: - Outlets
    // ---------------------------------------------------------
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!

    // ---------------------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup collection view
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

    // ---------------------------------------------------------
    // MARK: - Data Reloading
    // ---------------------------------------------------------
    func reloadMedications() {
        medications = MedicationDataStore.shared.medications
        collectionView.reloadData()
    }

    func didUpdateMedication() {
        reloadMedications()
    }

    // ---------------------------------------------------------
    // MARK: - Actions
    // ---------------------------------------------------------
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        delegate?.didUpdateMedication()
        dismiss(animated: true)
    }

    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    // ---------------------------------------------------------
    // MARK: - Collection Selection
    // ---------------------------------------------------------
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

//
// MARK: - CollectionView DataSource
//
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

//
// MARK: - CollectionView Layout
//
extension EditMedicationViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 110)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {   
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

