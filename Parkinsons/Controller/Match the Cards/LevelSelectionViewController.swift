//
//  LevelSelectionViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class LevelSelectionViewController: UIViewController {

    
    @IBOutlet weak var datePickerUIView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerUIView.applyCardStyle()
        playButton.isEnabled = true
        let calendar = Calendar.current
        let now = Date()
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year,.month], from: now))!
        let range = calendar.range(of: .day, in: .month, for: now)!
        let endOfMonth = calendar.date(byAdding: .day, value: range.count - 1 ,to: startOfMonth)!
        
        datePickerOutlet.minimumDate = startOfMonth
        datePickerOutlet.maximumDate = min(endOfMonth, now)
        datePickerOutlet.datePickerMode = .date
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playButton.isEnabled = true
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        let date = datePickerOutlet.date
        let manager = DailyGameManager.shared
        
        if manager.isOutsideCurrentMonth(date: date) {
           alert("This date is in future. You can't play it yet")
            sender.isEnabled = true
            return
        }
        if manager.isFuture(date: date) {
            alert("This levels are locked")
            sender.isEnabled = true
            return
        }
        
        if manager.isCompleted(date: date) {
            alert("Game for this day is already completed")
            sender.isEnabled = true
            return
        }
        
        if manager.isAttempted(date: date) {
            alert("You already attempted this day and cannot retry")
            sender.isEnabled = true
            return
        }
        
        
        let storyboard = UIStoryboard(name: "Match the Cards", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        
        vc.selectedDate = date
        vc.level = manager.level(for: date)
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func alert(_ text: String) {
        let alert = UIAlertController(title: "Not Allowed", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(alert, animated: true)
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
