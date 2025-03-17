import SwiftUI
import AVKit

struct VideoInteractionView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @State private var showingCamera = false
    @State private var recordedVideoURL: URL?
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    @State private var showingInstructions = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // AI Assistant Video Player
                ZStack {
                    VideoPlayer(player: AVPlayer(url: appState.assistantVideos[.incomeVerification]!))
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: AppStyle.cornerRadius))
                        .shadow(color: AppStyle.shadowColor, radius: 10)
                    
                    // Video overlay when not playing
                    if showingInstructions {
                        videoInstructionsOverlay
                    }
                }
                
                // Instructions Card
                instructionsCard
                
                // Response Section
                responseSection
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(AppStyle.backgroundColor)
        .sheet(isPresented: $showingCamera) {
            CameraView(videoURL: $recordedVideoURL)
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
                // Show recorded video preview
                VideoPlayer(player: AVPlayer(url: recordedVideo))
                    .frame(height: 200)
                    .cornerRadius(AppStyle.cornerRadius)
                
                HStack(spacing: 16) {
                    Button("Re-record") {
                        recordedVideoURL = nil
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Continue") {
                        withAnimation {
                            appState.currentStep = .documentUpload
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            } else {
                // Record button
                Button(action: {
                    showingCamera = true
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
    }
}

#Preview {
    VideoInteractionView()
        .environmentObject(LoanApplicationState())
} 