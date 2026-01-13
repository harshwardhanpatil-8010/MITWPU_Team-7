import UIKit
import AVFoundation

class EmojiGameViewController: UIViewController {

    // Link this to your orange view in Storyboard
    @IBOutlet weak var cameraContainerView: CameraPreviewView!
    
    @IBOutlet weak var backgroundCard: UIView!
    var captureSession: AVCaptureSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    func setupUI() {
        // 1. Round the corners of the white background card
        backgroundCard.layer.cornerRadius = 24
        
        // 2. Add the Shadow to the background card
        backgroundCard.layer.shadowColor = UIColor.black.cgColor
        backgroundCard.layer.shadowOpacity = 0.15  // Softness of shadow
        backgroundCard.layer.shadowOffset = CGSize(width: 0, height: 10) // Drop it down
        backgroundCard.layer.shadowRadius = 15     // Blur amount
        backgroundCard.layer.masksToBounds = false // Important: Allows shadow to show outside
        
        // 3. Round the corners of the Camera View specifically
        cameraContainerView.layer.cornerRadius = 20
        cameraContainerView.layer.masksToBounds = true // Important: Clips the camera feed to the corners
        
        // 4. Match the background color to a clean white if it isn't already
        backgroundCard.backgroundColor = .white
    }
    func setupCamera() {
        // Check if cameraContainerView is actually connected
        guard cameraContainerView != nil else {
            print("Error: cameraContainerView is nil. Check Storyboard Outlets.")
            return
        }

        captureSession = AVCaptureSession()
        
        // For Simulator safety, keep this guard:
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }

            // Apply the session to the layer
            let previewLayer = cameraContainerView.videoPreviewLayer
            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        } catch {
            print("Camera error: \(error)")
        }
    }
}
