//
//  EditLogViewController.swift
//  Parkinsons
//
//  Created by Zeeshan Khan on 15/01/26.
//

import UIKit

protocol EditLogDelegate: AnyObject {
    func didUpdateLoggedDoses(_ updated: [LoggedDoseItem])
}

class EditLogViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: EditLogDelegate?

    var loggedDoses: [LoggedDoseItem] = []  

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Logs"

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            UINib(nibName: "EditLogCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "EditLogCell"
        )
    }
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        delegate?.didUpdateLoggedDoses(loggedDoses)
            dismiss(animated: true)
    }
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    
}
extension EditLogViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        loggedDoses.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EditLogCell",
            for: indexPath
        ) as! EditLogCollectionViewCell

        let item = loggedDoses[indexPath.item]
        cell.configure(with: item)

        cell.onStatusChange = { [weak self] newStatus in
            guard let self = self else { return }
            
            self.loggedDoses[indexPath.item].status = newStatus
            
            DoseLogDataStore.shared.updateLogStatus(
                logID: item.id,
                status: DoseStatus(from: newStatus)
            )
            
            NotificationCenter.default.post(
                name: NSNotification.Name("MedicationLogged"),
                object: nil
            )
        }

        return cell
    }
}
extension EditLogViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width - 32 , height: 110)
    }


    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        8
    }
}
