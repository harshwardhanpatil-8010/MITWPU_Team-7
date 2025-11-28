//
//  RepeatViewController.swift
//  Parkinsons
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class RepeatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var RepeatTableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repeatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RepeatTableViewCell
        let type = repeatList[indexPath.row]
        cell.configureCell(type: type)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        for i in 0..<repeatList.count {
            repeatList[i].isSelected = (i == indexPath.row)
        }
        print(repeatList)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        RepeatTableView.layer.cornerRadius = 10
        RepeatTableView.clipsToBounds = true
        RepeatTableView.backgroundColor = UIColor.systemGray6
        RepeatTableView.delegate = self
        RepeatTableView.dataSource = self
        // Do any additional setup after loading the view.
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
