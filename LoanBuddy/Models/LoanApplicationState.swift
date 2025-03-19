import SwiftUI
import Combine

class LoanApplicationState: ObservableObject {
    @Published var userData: UserData
    @Published var currentStep: ApplicationStep
    @Published var isRecording: Bool
    @Published var isProcessing: Bool
    
    init() {
        self.userData = UserData()
        self.currentStep = .welcome
        self.isRecording = false
        self.isProcessing = false
    }
    
    // Placeholder for video URLs of the AI assistant
    let assistantVideos: [ApplicationStep: URL] = [
        .welcome: URL(string: "https://example.com/welcome.mp4")!,
        .incomeVerification: URL(string: "https://example.com/income.mp4")!,
        .documentUpload: URL(string: "https://example.com/documents.mp4")!,
        .result: URL(string: "https://example.com/result.mp4")!
    ]
    
    // Add more functionality
    func startNewApplication() {
        userData = UserData()
        currentStep = .welcome
        userData.applicationStatus = .inProgress
    }
    
    func processIncome(_ amount: Double) {
        userData.income = amount
        // Basic eligibility check
        isEligible = amount >= 20000
    }
    
    var isEligible: Bool = false {
        didSet {
            userData.applicationStatus = isEligible ? .approved : .rejected
        }
    }
    
    func resetApplication() {
        userData = UserData()
        currentStep = .welcome
        isRecording = false
        isProcessing = false
    }
    
    func evaluateLoanApplication() {
        // Check if all required documents are verified
        let verifiedDocuments = userData.documents.filter { $0.isVerified }
        guard verifiedDocuments.count == DocumentType.allCases.count else {
            addActivity(
                title: "Document Verification Failed",
                description: "Please ensure all documents are verified",
                type: .failure
            )
            userData.applicationStatus = .needsMoreInfo
            return
        }
        
        // Extract income from documents
        let extractedIncome = verifiedDocuments
            .first { $0.type == .incomeProof }?
            .extractedDetails?
            .income
        
        guard let incomeStr = extractedIncome,
              let monthlyIncome = Double(incomeStr) else {
            addActivity(
                title: "Income Verification Failed",
                description: "Unable to verify income details",
                type: .failure
            )
            userData.applicationStatus = .rejected
            return
        }
        
        // Calculate loan eligibility
        let maxLoanAmount = monthlyIncome * 36 // 3 years worth of income
        let monthlyEMI = calculateEMI(
            principal: userData.loanAmount,
            ratePerAnnum: 12.0, // 12% per annum
            tenureMonths: userData.loanPeriod
        )
        
        // Check if EMI is affordable (not more than 50% of monthly income)
        let isEMIAffordable = monthlyEMI <= (monthlyIncome * 0.5)
        // Check if loan amount is within limits
        let isAmountWithinLimit = userData.loanAmount <= maxLoanAmount
        
        if isEMIAffordable && isAmountWithinLimit {
            userData.applicationStatus = .approved
            addActivity(
                title: "Loan Approved",
                description: "Congratulations! Your loan for ₹\(Int(userData.loanAmount)) has been approved",
                type: .success
            )
        } else {
            userData.applicationStatus = .rejected
            let reason = !isEMIAffordable ? "EMI exceeds income limit" : "Loan amount exceeds eligibility"
            addActivity(
                title: "Loan Application Rejected",
                description: reason,
                type: .failure
            )
        }
    }
    
    private func calculateEMI(principal: Double, ratePerAnnum: Double, tenureMonths: Int) -> Double {
        let r = ratePerAnnum / (12 * 100) // Monthly interest rate
        let n = Double(tenureMonths)
        let emi = principal * r * pow(1 + r, n) / (pow(1 + r, n) - 1)
        return emi
    }
    
    private func addActivity(title: String, description: String, type: ActivityType) {
        let activity = RecentActivity(title: title, description: description, type: type)
        userData.recentActivities.insert(activity, at: 0)
        // Keep only last 5 activities
        if userData.recentActivities.count > 5 {
            userData.recentActivities.removeLast()
        }
    }
}

enum ApplicationStep: Int, CaseIterable {
    case welcome
    case languageSelection
    case incomeVerification
    case documentUpload
    case result
    
    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .languageSelection: return "Select Language"
        case .incomeVerification: return "Income Details"
        case .documentUpload: return "Upload Documents"
        case .result: return "Application Result"
        }
    }
} 