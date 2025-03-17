import SwiftUI

struct MainNavigationView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                switch appState.currentStep {
                case .welcome:
                    WelcomeView()
                case .languageSelection:
                    LanguageSelectionView()
                case .incomeVerification:
                    VideoInteractionView()
                case .documentUpload:
                    DocumentUploadView()
                case .result:
                    EligibilityResultView()
                }
            }
            .navigationTitle(appState.currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if appState.currentStep != .welcome {
                        Button(action: {
                            withAnimation {
                                if appState.currentStep == .languageSelection {
                                    dismiss()
                                } else {
                                    appState.currentStep = ApplicationStep(rawValue: appState.currentStep.rawValue - 1) ?? .welcome
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .imageScale(.large)
                        }
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .environmentObject(appState)
    }
} 