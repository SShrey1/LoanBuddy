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