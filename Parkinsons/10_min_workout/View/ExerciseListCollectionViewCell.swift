import UIKit
import AVFoundation

class ExerciseListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailOutlet: UIImageView!
    @IBOutlet weak var exerciseNameOutlet: UILabel!
    @IBOutlet weak var repsOutlet: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailOutlet.layer.cornerRadius = 10
        thumbnailOutlet.clipsToBounds = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailOutlet.image = nil
    }
    
    func configureCompleted() {
        exerciseNameOutlet.textColor = .systemGray
        repsOutlet.textColor = .systemGray2
        thumbnailOutlet.alpha = 0.3
    }

    func configurePendingOrSkipped() {
        exerciseNameOutlet.textColor = .label
        repsOutlet.textColor = .secondaryLabel
        thumbnailOutlet.alpha = 1
    }

    func loadThumbnail(videoName: String) {
        DispatchQueue.global(qos: .userInitiated).async {

            guard let url = Bundle.main.url(
                forResource: videoName,
                withExtension: "mp4"
            ) else { return }

            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true

            let time = CMTime(seconds: 0.0, preferredTimescale: 600)

            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: cgImage)

                DispatchQueue.main.async {
                    self.thumbnailOutlet.image = image
                }
            } catch {
               
            }
        }
    }
}
