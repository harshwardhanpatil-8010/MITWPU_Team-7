//
//  ExerciseTableViewCell.swift
//  Parkinsons
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var checkMarkImageOutlet: UIImageView!
    
    @IBOutlet weak var exerciseImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func loadThumbnail(videoID: String) {
        let urlString = "https://img.youtube.com/vi/\(videoID)/mqdefault.jpg"
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
            let image = UIImage(data: data){
                DispatchQueue.main.async {
                    self.exerciseImage.image = image
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
