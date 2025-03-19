import SwiftUI
import AVFoundation

struct VideoRecordingView: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.cameraCaptureMode = .video
        picker.videoMaximumDuration = 60 // 1 minute max
        picker.allowsEditing = false // Disable editing to keep it simple
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoRecordingView
        
        init(parent: VideoRecordingView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileName = "recorded_video_\(Date().timeIntervalSince1970).mov" // Unique filename
                let destinationURL = documentsDirectory.appendingPathComponent(fileName)
                
                do {
                    try FileManager.default.copyItem(at: videoURL, to: destinationURL)
                    parent.videoURL = destinationURL
                    print("Video saved to: \(destinationURL)") // Debug log
                } catch {
                    print("Failed to save video: \(error)")
                }
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
