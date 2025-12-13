//
//  EditMedicationViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class EditMedicationViewController: UIViewController, UICollectionViewDelegate {
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    var medications: [Medication] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            UINib(nibName: "EditMedicationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "EditMedCell"
        )
    }

//    private func setupUI() {
//        guard let medication = medication, let dose = dose else { return }
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = medications[indexPath.row]

        let storyboard = UIStoryboard(name: "Medication", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "AddMedVC"
        ) as! AddMedicationViewController

        vc.isEditMode = true                 // IMPORTANT
        vc.medicationToEdit = selected       // PASS MEDICATION OBJECT

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
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
extension EditMedicationViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medications.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditMedCell", for: indexPath) as! EditMedicationCollectionViewCell
        cell.configure(with: medications[indexPath.row])
        return cell
    }
    
}

extension EditMedicationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width - 32, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
