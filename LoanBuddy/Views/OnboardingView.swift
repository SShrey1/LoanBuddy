import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0
    
    let pages: [(image: String, title: String, description: String)] = [
        ("video.fill", "Video Interactions", "Talk to our AI assistant naturally through video"),
        ("doc.text.fill", "Easy Documentation", "Upload documents quickly using your camera"),
        ("checkmark.circle.fill", "Quick Approval", "Get instant eligibility feedback"),
        ("globe", "Multi-Language Support", "Communicate in your preferred language")
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.white, AppStyle.backgroundColor]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count) { index in
                    OnboardingPage(
                        image: pages[index].image,
                        title: pages[index].title,
                        description: pages[index].description,
                        isLastPage: index == pages.count - 1,
                        action: {
                            withAnimation {
                                hasSeenOnboarding = true
                            }
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Skip button in top left corner
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            hasSeenOnboarding = true
                        }
                    }) {
                        Text("Skip")
                            .font(AppStyle.TextStyle.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(20)
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                .padding(.top, 48)
                
                Spacer()
            }
        }
        .onAppear {
            // Ensure onboarding starts fresh
            currentPage = 0
        }
    }
}

struct OnboardingPage: View {
    let image: String
    let title: String
    let description: String
    let isLastPage: Bool
    let action: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: image)
                .font(.system(size: 100))
                .foregroundColor(AppStyle.primaryColor)
                .scaleEffect(isAnimating ? 1 : 0.5)
                .opacity(isAnimating ? 1 : 0)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(AppStyle.TextStyle.title)
                    .multilineTextAlignment(.center)
                    .offset(y: isAnimating ? 0 : 20)
                    .opacity(isAnimating ? 1 : 0)
                
                Text(description)
                    .font(AppStyle.TextStyle.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .offset(y: isAnimating ? 0 : 20)
                    .opacity(isAnimating ? 1 : 0)
            }
            
            Spacer()
            
            if isLastPage {
                Button(action: action) {
                    Text("Get Started")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 40)
                .opacity(isAnimating ? 1 : 0)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
} 