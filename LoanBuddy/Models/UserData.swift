import Foundation

struct UserData: Codable {
    var name: String = ""
    var email: String = ""
    var selectedLanguage: Language = .english
    var income: Double = 0
    var documents: [Document] = []
    var applicationStatus: ApplicationStatus = .notStarted
}

enum Language: String, Codable, CaseIterable {
    case english = "English"
    case hindi = "Hindi"
    case tamil = "Tamil"
    case telugu = "Telugu"
    
    var welcomeMessage: String {
        switch self {
        case .english: return "Welcome to LoanBuddy"
        case .hindi: return "लोन बडी में आपका स्वागत है"
        case .tamil: return "வாங்கியிருக்கின்றேன்"
        case .telugu: return "వాళ్లు స్వాగతం"
        }
    }
}

enum ApplicationStatus: String, Codable {
    case notStarted = ""
    case inProgress = "In Progress"
    case approved = "Approved"
    case rejected = "Rejected"
    case needsMoreInfo = "Needs More Information"
}

struct Document: Identifiable, Codable {
    let id: UUID
    let type: DocumentType
    var imageData: Data?
    var isVerified: Bool
    
    init(type: DocumentType, imageData: Data? = nil, isVerified: Bool = false) {
        self.id = UUID()
        self.type = type
        self.imageData = imageData
        self.isVerified = isVerified
    }
}

enum DocumentType: String, Codable, CaseIterable {
    case aadhaar = "Aadhaar Card"
    case pan = "PAN Card"
    case incomeProof = "Income Proof"
} 