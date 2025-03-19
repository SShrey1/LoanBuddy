import SwiftUI
import AVKit

struct WelcomeView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    
    var body: some View {
        VStack(spacing: 20) {
            // Placeholder for AI assistant video player
            VideoPlayer(player: AVPlayer(url: appState.assistantVideos[.welcome]!))
                .frame(height: 300)
                .cornerRadius(12)
            
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
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
} 
