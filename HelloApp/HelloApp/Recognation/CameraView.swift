import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {

    var onImageCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.onImageCaptured = onImageCaptured
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
