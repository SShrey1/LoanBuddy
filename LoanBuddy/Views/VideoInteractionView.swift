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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    VideoPlayer(player: AVPlayer(url: appState.assistantVideos[.incomeVerification]!))
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: AppStyle.cornerRadius))
                        .shadow(color: AppStyle.shadowColor, radius: 10)
                    
                    if showingInstructions {
                        videoInstructionsOverlay
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
                    // Ensure the video URL is set after recording
                    if let url = recordedVideoURL {
                        print("Video recorded at: \(url)") // Debug log
                    }
                }
        }
    }
    
    private var videoInstructionsOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "play.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
                .opacity(isAnimating ? 0.8 : 1)
                .scaleEffect(isAnimating ? 1.1 : 1)
                .animation(.easeInOut(duration: 1).repeatForever(), value: isAnimating)
            
            Text("Tap to watch AI assistant's message")
                .font(AppStyle.TextStyle.caption)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.black.opacity(0.6))
                .cornerRadius(20)
        }
        .onTapGesture {
            withAnimation {
                showingInstructions = false
            }
        }
        .onAppear {
            isAnimating = true
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
                            showingCamera = true // This triggers the camera sheet
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
    
    private func showPermissionsAlert() {
        let alert = UIAlertController(
            title: "Permissions Required",
            message: "Please enable camera and microphone access in Settings to record video responses.",
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
    
    private func requestCameraAndMicrophonePermissions(completion: @escaping (Bool) -> Void) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch (cameraStatus, microphoneStatus) {
        case (.authorized, .authorized):
            completion(true)
        case (.notDetermined, .notDetermined):
            AVCaptureDevice.requestAccess(for: .video) { videoGranted in
                AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
                    DispatchQueue.main.async {
                        completion(videoGranted && audioGranted)
                    }
                }
            }
        default:
            completion(false)
            showPermissionsAlert()
        }
    }
}

#Preview {
    VideoInteractionView()
        .environmentObject(LoanApplicationState())
}
