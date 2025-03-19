import SwiftUI
import AVKit

struct WelcomeView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showVideoError = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Video player with local file
            ZStack {
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(height: 300)
                        .cornerRadius(12)
                        .onAppear {
                            // Auto-play when view appears
                            print("Video player appeared")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                player.play()
                                isPlaying = true
                            }
                        }
                        .onDisappear {
                            // Cleanup when view disappears
                            player.pause()
                            player.seek(to: .zero)
                            isPlaying = false
                        }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 300)
                        .cornerRadius(12)
                        .overlay(
                            Text("Loading video...")
                                .foregroundColor(.secondary)
                        )
                }
            }
            
            Text("Meet Vansh, Your AI Loan Manager")
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text("Get your loan approved through simple video interactions")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                withAnimation {
                    appState.currentStep = .languageSelection
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppStyle.primaryColor)
                    .cornerRadius(AppStyle.cornerRadius)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            setupPlayer()
        }
        .alert("Video Error", isPresented: $showVideoError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Could not load the welcome video")
        }
    }
    
    private func setupPlayer() {
        // Debug: Print bundle information
        print("Main bundle path: \(Bundle.main.bundlePath)")
        
        if let resourcePath = Bundle.main.resourcePath {
            print("Resource path: \(resourcePath)")
            let enumerator = FileManager.default.enumerator(atPath: resourcePath)
            print("Bundle contents:")
            while let filePath = enumerator?.nextObject() as? String {
                if filePath.contains("welcomeenglish") || 
                   filePath.contains("englishins") || 
                   filePath.contains("hindins") {
                    print("Video found: \(filePath)")
                }
            }
        }
        
        if let url = appState.getVideoURLForStep(.welcome) {
            print("Successfully found welcome video")
            player = AVPlayer(url: url)
            
            // Add observer for video completion
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem,
                queue: .main
            ) { _ in
                isPlaying = false
                player?.seek(to: .zero)
            }
        } else {
            print("Could not find welcome video")
            showVideoError = true
        }
    }
} 
