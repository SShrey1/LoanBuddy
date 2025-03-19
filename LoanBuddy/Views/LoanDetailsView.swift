import SwiftUI

struct LoanDetailsView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @Environment(\.dismiss) private var dismiss
    @State private var loanAmount: String = ""
    @State private var loanPeriod: String = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Loan Amount Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Loan Amount")
                            .font(.headline)
                        
                        HStack {
                            Text("₹")
                                .foregroundColor(.secondary)
                            TextField("Enter amount", text: $loanAmount)
                                .keyboardType(.numberPad)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(AppStyle.cornerRadius)
                    }
                    
                    // Loan Period Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Loan Period (in months)")
                            .font(.headline)
                        
                        TextField("Enter months", text: $loanPeriod)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(AppStyle.cornerRadius)
                    }
                    
                    // Submit Button
                    Button(action: submitLoanDetails) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppStyle.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(AppStyle.cornerRadius)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Loan Details")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
            .alert("Invalid Input", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter valid loan amount and period")
            }
        }
    }
    
    private func submitLoanDetails() {
        guard let amount = Double(loanAmount),
              let period = Int(loanPeriod),
              amount > 0,
              period > 0 else {
            showError = true
            return
        }
        
        // Save loan details to app state
        appState.userData.loanAmount = amount
        appState.userData.loanPeriod = period
        
        // Check if all documents are verified before evaluating
        let verifiedDocuments = appState.userData.documents.filter { $0.isVerified }
        if verifiedDocuments.count == DocumentType.allCases.count {
            // Evaluate loan application
            appState.evaluateLoanApplication()
        } else {
            // Add activity about missing documents
            let activity = RecentActivity(
                title: "Documents Required",
                description: "Please upload and verify all required documents before applying for loan",
                type: .info
            )
            appState.userData.recentActivities.insert(activity, at: 0)
        }
        
        dismiss()
    }
} 
