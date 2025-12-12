//
//  EditMedicationViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class EditMedicationViewController: UIViewController, UICollectionViewDelegate {
    

    @IBOutlet weak var collectionView: UICollectionView!
    var medication: Medication!
    var dose: MedicationDose?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        collectionView.dataSource = self
        collectionView.delegate = self

                // Register cell
        collectionView.register(UINib(nibName: "EditMedCell", bundle: nil),
                                        forCellWithReuseIdentifier: "EditMedCell")
        // Do any additional setup after loading the view.
    }
    private func setupUI() {
            guard let medication = medication, let dose = dose else { return }

//            titleLabel.text = medication.name
//            subtitleLabel.text = medication.form
//            scheduleLabel.text = medication.schedule
//            medIcon.image = UIImage(named: medication.iconName)
//
//            // Format time
//            let formatter = DateFormatter()
//            formatter.dateFormat = "hh:mm"
//            timeLabel.text = formatter.string(from: dose.time)
//
//            formatter.dateFormat = "a"
//            ampmLabel.text = formatter.string(from: dose.time)
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
        return medication.doses.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditMedCell", for: indexPath) as! EditMedicationCollectionViewCell
        
        let dose = medication.doses[indexPath.row]
        cell.configure(with: dose, medication: medication)

        
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
