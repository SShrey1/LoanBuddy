import SwiftUI
import AVKit

struct VideoInteractionView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @State private var showingCamera = false
    @State private var recordedVideoURL: URL?
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    @State private var showingInstructions = true
    @State private var showFaceMatchError = false
    @State private var player: AVPlayer?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    if let videoURL = appState.getVideoURLForStep(.incomeVerification) {
                        VideoPlayer(player: player ?? AVPlayer(url: videoURL))
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: AppStyle.cornerRadius))
                            .shadow(color: AppStyle.shadowColor, radius: 10)
                            .onAppear {
                                player = AVPlayer(url: videoURL)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    player?.play()
                                }
                                withAnimation {
                                    showingInstructions = false
                                }
                            }
                            .onDisappear {
                                player?.pause()
                                player?.seek(to: .zero)
                                player = nil
                            }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: AppStyle.cornerRadius))
                            .overlay(
                                Text("Video not available")
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                
                instructionsCard
                
                responseSection
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(AppStyle.backgroundColor)
        .sheet(isPresented: $showingCamera) {
            VideoRecordingView(videoURL: $recordedVideoURL)
                .onDisappear {
                    if let url = recordedVideoURL {
                        print("Video recorded at: \(url)")
                    }
                }
        }
    }
    
    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Income Verification")
                .font(AppStyle.TextStyle.heading)
            
            VStack(alignment: .leading, spacing: 12) {
                instructionRow(number: 1, text: "Watch the AI assistant's message")
                instructionRow(number: 2, text: "Record your response stating your monthly income")
                instructionRow(number: 3, text: "Speak clearly and face the camera")
            }
        }
        .padding()
        .background(AppStyle.CardStyle.shadow)
    }
    
    private func instructionRow(number: Int, text: String) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(AppStyle.TextStyle.caption)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(AppStyle.primaryColor)
                .clipShape(Circle())
            
            Text(text)
                .font(AppStyle.TextStyle.body)
                .foregroundColor(.secondary)
        }
    }
    
    private var responseSection: some View {
        VStack(spacing: 20) {
            if let recordedVideo = recordedVideoURL {
                VideoPlayer(player: AVPlayer(url: recordedVideo))
                    .frame(height: 200)
                    .cornerRadius(AppStyle.cornerRadius)
                
                HStack(spacing: 16) {
                    Button("Re-record") {
                        recordedVideoURL = nil
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Continue") {
                        FaceMatchingService.shared.matchFaceInVideo(url: recordedVideo) { isMatch in
                            if isMatch {
                                withAnimation {
                                    appState.currentStep = .documentUpload
                                }
                            } else {
                                showFaceMatchError = true
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            } else {
                Button(action: {
                    requestCameraAndMicrophonePermissions { granted in
                        if granted {
                            showingCamera = true
                        } else {
                            print("Camera or microphone access denied.")
                            showPermissionsAlert()
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "video.circle.fill")
                            .font(.title2)
                        Text("Record Your Response")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .alert("Face Verification Failed", isPresented: $showFaceMatchError) {
            Button("OK", role: .cancel) { }
            Button("Re-record", role: .destructive) {
                recordedVideoURL = nil
            }
        } message: {
            Text("The person in the video doesn't match the profile picture. Please ensure you're the same person who uploaded the profile picture.")
        }
    }
    
    private func requestCameraAndMicrophonePermissions(completion: @escaping (Bool) -> Void) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        let requestCamera = {
            AVCaptureDevice.requestAccess(for: .video) { videoGranted in
                if videoGranted {
                    AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
                        DispatchQueue.main.async {
                            completion(videoGranted && audioGranted)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        }
        
        switch (cameraStatus, microphoneStatus) {
        case (.authorized, .authorized):
            completion(true)
        case (.notDetermined, _):
            requestCamera()
        case (_, .notDetermined):
            AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
                if audioGranted {
                    requestCamera()
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        default:
            completion(false)
            showPermissionsAlert()
        }
    }
    
    private func showPermissionsAlert() {
        let alert = UIAlertController(
            title: "Permissions Required",
            message: "Camera and microphone access is required to record your income verification video. Please enable them in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}

#Preview {
    VideoInteractionView()
        .environmentObject(LoanApplicationState())
}
