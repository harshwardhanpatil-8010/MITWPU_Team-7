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
    
    
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
          super.awakeFromNib()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        thumbnailOutlet.layer.cornerRadius = 10
        thumbnailOutlet.clipsToBounds = true
      }

      func configureCompleted() {
          containerView.backgroundColor = .systemGray5
          exerciseNameOutlet.textColor = .systemGray
          repsOutlet.textColor = .systemGray
          thumbnailOutlet.alpha = 0.4
          isUserInteractionEnabled = false
      }

      func configurePending() {
          containerView.backgroundColor = .white
          exerciseNameOutlet.textColor = .label
          repsOutlet.textColor = .secondaryLabel
          thumbnailOutlet.alpha = 1.0
          isUserInteractionEnabled = true
      }

      func loadThumbnail(videoID: String) {
          let urlString = "https://img.youtube.com/vi/\(videoID)/0.jpg"
          if let url = URL(string: urlString) {
              DispatchQueue.global().async {
                  if let data = try? Data(contentsOf: url) {
                      DispatchQueue.main.async {
                          self.thumbnailOutlet.image = UIImage(data: data)
                      }
                  }
              }
          }
      }
  }
