import SwiftUI

struct EligibilityResultView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Status Icon
                Image(systemName: appState.isEligible ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(appState.isEligible ? .green : .blue)
                    .scaleEffect(isAnimating ? 1 : 0.6)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: isAnimating)
                
                // Status Card
                statusCard
                    .offset(y: isAnimating ? 0 : 50)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: isAnimating)
                
                // Details Card
                detailsCard
                    .offset(y: isAnimating ? 0 : 50)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: isAnimating)
                
                // Action Buttons
                actionButtons
                    .offset(y: isAnimating ? 0 : 50)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: isAnimating)
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(AppStyle.backgroundColor)
        .onAppear {
            isAnimating = true
        }
    }
    
    private var statusCard: some View {
        VStack(spacing: 16) {
            Text(statusTitle)
                .font(AppStyle.TextStyle.title)
                .multilineTextAlignment(.center)
            
            Text(statusMessage)
                .font(AppStyle.TextStyle.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppStyle.CardStyle.shadow)
    }
    
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Application Details")
                .font(AppStyle.TextStyle.heading)
            
            VStack(alignment: .leading, spacing: 12) {
                detailRow(title: "Application ID", value: "APP-\(UUID().uuidString.prefix(8))")
                detailRow(title: "Submitted On", value: Date().formatted(date: .abbreviated, time: .shortened))
                detailRow(title: "Processing Time", value: "2-3 business days")
                
                if appState.userData.applicationStatus == .approved {
                    detailRow(title: "Loan Amount", value: "₹50,000")
                    detailRow(title: "Interest Rate", value: "12% p.a.")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppStyle.CardStyle.shadow)
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppStyle.TextStyle.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(AppStyle.TextStyle.body)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            if appState.userData.applicationStatus == .approved {
                Button("Complete Application") {
                    // Handle loan completion
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Download Offer Letter") {
                    // Handle download
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Close") {
                    withAnimation {
                        appState.resetApplication()
                        dismiss()
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            } else {
                if appState.userData.applicationStatus == .needsMoreInfo {
                    Button("Provide Additional Information") {
                        // Handle additional information collection
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                
                Button("Start New Application") {
                    withAnimation {
                        appState.resetApplication()
                        dismiss()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
    
    private var statusTitle: String {
        switch appState.userData.applicationStatus {
        case .approved: return "Congratulations!"
        case .rejected: return "Application Not Approved"
        case .needsMoreInfo: return "Additional Information Needed"
        default: return "Processing"
        }
    }
    
    private var statusMessage: String {
        switch appState.userData.applicationStatus {
        case .approved:
            return "Your loan application has been approved. Please complete the remaining steps to finalize your loan."
        case .rejected:
            return "Unfortunately, we cannot approve your loan at this time. You can start a new application after 30 days."
        case .needsMoreInfo:
            return "We need some additional information to process your application. Please provide the requested details."
        default:
            return "Please wait while we process your application."
        }
    }
}

#Preview {
    EligibilityResultView()
        .environmentObject(LoanApplicationState())
} 
