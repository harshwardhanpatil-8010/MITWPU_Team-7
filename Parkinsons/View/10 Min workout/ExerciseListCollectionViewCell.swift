//
//  ExerciseListCollectionViewCell.swift
//  Parkinsons
//
//  Created by harshwardhan patil on 25/12/25.
//

import UIKit

class ExerciseListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailOutlet: UIImageView!
    @IBOutlet weak var exerciseNameOutlet: UILabel!
    @IBOutlet weak var repsOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailOutlet?.layer.cornerRadius = 10
        thumbnailOutlet?.clipsToBounds = true
    }
        
        func configureCompleted() {
            exerciseNameOutlet?.textColor = .systemGray
            repsOutlet?.textColor = .systemGray2
            thumbnailOutlet?.alpha = 0.3
        }
        
        func configurePendingOrSkipped() {
            exerciseNameOutlet?.textColor = .label
            repsOutlet?.textColor = .secondaryLabel
            thumbnailOutlet?.alpha = 1.0
        }
        
        func loadThumbnail(videoID: String) {
            let url = URL(string: "https://img.youtube.com/vi/\(videoID)/0.jpg")!
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { self.thumbnailOutlet.image = UIImage(data: data) }
                }
            }
        }
    }

