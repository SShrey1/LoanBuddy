import SwiftUI
import AVFoundation

struct CameraView: View {
    @Binding var videoURL: URL?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraModel()
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack(spacing: 20) {
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    // Record Button
                    Button(action: {
                        if camera.isRecording {
                            camera.stopRecording()
                        } else {
                            camera.startRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(camera.isRecording ? .red : .white)
                                .frame(width: 65, height: 65)
                            
                            if camera.isRecording {
                                Circle()
                                    .stroke(.white, lineWidth: 4)
                                    .frame(width: 75, height: 75)
                            }
                        }
                    }
                    
                    // Flip Camera
                    Button(action: {
                        camera.flipCamera()
                    }) {
                        Image(systemName: "camera.rotate.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            camera.checkPermissions()
        }
        .onChange(of: camera.recordedURL) { url in
            if let url = url {
                videoURL = url
                dismiss()
            }
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