//
//  SetGoalViewController.swift
//  Parkinson's App
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class SetGoalViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
        cell.textLabel?.text = "\(session[indexPath.row].title)"
        
        return cell
    }
    


    
    @IBOutlet weak var sessionTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        sessionTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Removes old sessions (yesterday) automatically
//        DataStore.shared.cleanupOldSessions()
//
//        // Refresh your UITableView/CollectionView
//        sessionsTableView.reloadData()
//    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
