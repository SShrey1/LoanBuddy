import SwiftUI
import AVFoundation
import UIKit

struct CameraView: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage) -> Void
        
        init(onImageCaptured: @escaping (UIImage) -> Void) {
            self.onImageCaptured = onImageCaptured
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// Camera Preview
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Camera Model
class CameraModel: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var isRecording = false
    @Published var recordedURL: URL?
    @Published var showAlert = false
    @Published var alertError: String = ""
    
    var session = AVCaptureSession()
    var preview: AVCaptureVideoPreviewLayer!
    
    private var videoOutput = AVCaptureMovieFileOutput()
    private var audioOutput = AVCaptureAudioDataOutput()
    private var currentCamera: AVCaptureDevice?
    
    override init() {
        super.init()
        setupSession()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
                if status {
                    DispatchQueue.main.async {
                        self?.setupSession()
                    }
                }
            }
        default:
            showAlert = true
            alertError = "Please enable camera access in settings"
        }
    }
    
    private func setupSession() {
        do {
            session.beginConfiguration()
            
            // Add video input
            let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            currentCamera = videoDevice
            
            guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice!) else {
                return
            }
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            
            // Add audio input
            if let audioDevice = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
                if session.canAddInput(audioInput) {
                    session.addInput(audioInput)
                }
            }
            
            // Add video output
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.session.startRunning()
            }
            
        } catch {
            showAlert = true
            alertError = error.localizedDescription
        }
    }
    
    func startRecording() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
        videoOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording() {
        videoOutput.stopRecording()
        isRecording = false
    }
    
    func flipCamera() {
        session.beginConfiguration()
        
        // Remove existing input
        guard let currentInput = session.inputs.first as? AVCaptureDeviceInput else { return }
        session.removeInput(currentInput)
        
        // Add new input
        let newPosition: AVCaptureDevice.Position = currentInput.device.position == .front ? .back : .front
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }
        
        if session.canAddInput(newInput) {
            session.addInput(newInput)
        }
        
        session.commitConfiguration()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            return
        }
        
        recordedURL = outputFileURL
    }
} 