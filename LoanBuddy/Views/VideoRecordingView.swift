import SwiftUI
import AVKit

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
        picker.videoExportPreset = AVAssetExportPresetHighestQuality // Set high quality
        picker.allowsEditing = false
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
                // Create a unique filename with timestamp
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileName = "income_verification_\(Date().timeIntervalSince1970).mp4"
                let destinationURL = documentsDirectory.appendingPathComponent(fileName)
                
                // Convert and save video to mp4
                convertAndSaveVideo(from: videoURL, to: destinationURL) { success, error in
                    if success {
                        DispatchQueue.main.async {
                            self.parent.videoURL = destinationURL
                            print("Video saved successfully at: \(destinationURL)")
                        }
                    } else if let error = error {
                        print("Error saving video: \(error.localizedDescription)")
                    }
                }
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
        
        private func convertAndSaveVideo(from sourceURL: URL, to destinationURL: URL, completion: @escaping (Bool, Error?) -> Void) {
            let asset = AVAsset(url: sourceURL)
            
            guard let exportSession = AVAssetExportSession(
                asset: asset,
                presetName: AVAssetExportPresetHighestQuality
            ) else {
                completion(false, nil)
                return
            }
            
            exportSession.outputURL = destinationURL
            exportSession.outputFileType = .mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    completion(true, nil)
                case .failed:
                    completion(false, exportSession.error)
                case .cancelled:
                    completion(false, nil)
                default:
                    completion(false, nil)
                }
            }
        }
    }
}
