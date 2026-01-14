import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    
    // 1. This tells the system that this view's background layer
    //    is specifically for video previews.
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    // 2. This helper property just casts the existing layer.
    //    It MUST NOT call itself.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
