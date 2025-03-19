import SwiftUI

struct LoanDetailsView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @Environment(\.dismiss) private var dismiss
    @State private var loanAmount: String = ""
    @State private var loanPeriod: String = ""
    @State private var showError = false
    
    // Add computed properties for validation
    private var isValidAmount: Bool {
        guard let amount = Double(loanAmount) else { return false }
        return amount > 0 && amount <= 1000000 // Max 10 lakhs
    }
    
    private var isValidPeriod: Bool {
        guard let period = Int(loanPeriod) else { return false }
        return period > 0 && period <= 60 // Max 5 years
    }
    
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
                        
                        amountValidation // Add validation message
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
                        
                        periodValidation // Add validation message
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
                Text("Please check your loan amount and period")
                    .foregroundColor(.blue)
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
    
    private var amountValidation: some View {
        Group {
            if !loanAmount.isEmpty && !isValidAmount {
                Text("Please enter a valid amount (up to ₹10,00,000)")
                    .font(AppStyle.TextStyle.caption)
                    .foregroundColor(.blue)
            } else {
                EmptyView()
            }
        }
    }
    
    private var periodValidation: some View {
        Group {
            if !loanPeriod.isEmpty && !isValidPeriod {
                Text("Please enter a valid period (1-60 months)")
                    .font(AppStyle.TextStyle.caption)
                    .foregroundColor(.blue)
            } else {
                EmptyView()
            }
        }
    }
} 
