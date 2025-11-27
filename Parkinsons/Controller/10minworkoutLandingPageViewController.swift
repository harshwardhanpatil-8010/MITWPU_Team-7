//
//  10minworkoutLandingPageViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class _0minworkoutLandingPageViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var rightInfoBarButton: UINavigationItem!
    
    @IBOutlet weak var startButtonOutlet: UIButton!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        exerciselist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exercise_cell", for: indexPath) as! ExerciseTableViewCell
        let exercise = exerciselist[indexPath.row]
        cell.configureCell(exercise: exercise)
        
        return cell
    }
    

    @IBOutlet weak var exerciseTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let infoButton = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(infoButtonTapped)
        )
        
        rightInfoBarButton.rightBarButtonItem = infoButton
        
        exerciseTableView.layer.cornerRadius = 10
        exerciseTableView.clipsToBounds = true
        exerciseTableView.backgroundColor = UIColor.systemGray6
        exerciseTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    @IBAction func startButtonAction(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "10 minworkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "10minworkoutCountdownViewController") as! _0minworkoutCountdownViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical   // Default push-like (slides from bottom)

        // For push-like slide from right animation:
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromRight
        view.window?.layer.add(transition, forKey: kCATransition)
        present(vc, animated: false)


        

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func infoButtonTapped() {
        
    }

}
