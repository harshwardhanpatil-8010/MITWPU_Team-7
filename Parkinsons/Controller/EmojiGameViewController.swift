import UIKit
import AVFoundation

class EmojiGameViewController: UIViewController {

    // Link this to your orange view in Storyboard
    @IBOutlet weak var cameraContainerView: CameraPreviewView!
    
    var captureSession: AVCaptureSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
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
