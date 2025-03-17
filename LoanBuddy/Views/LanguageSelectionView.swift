import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Choose Your Preferred Language")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            ForEach(Language.allCases, id: \.self) { language in
                Button(action: {
                    appState.userData.selectedLanguage = language
                    withAnimation {
                        appState.currentStep = .incomeVerification
                    }
                }) {
                    HStack {
                        Text(language.rawValue)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }
} 