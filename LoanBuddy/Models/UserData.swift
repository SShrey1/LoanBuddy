import Foundation
import UIKit

struct UserData: Codable {
    var name: String = ""
    var email: String = ""
    var selectedLanguage: Language = .english
    var income: Double = 0
    var documents: [Document] = []
    var applicationStatus: ApplicationStatus = .notStarted
    var profileImage: Data? = nil // Add this property
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
    
    var appLanguage: String {
        switch self {
        case .english: return "en"
        case .hindi: return "hi"
        case .tamil: return "ta"
        case .telugu: return "te"
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

enum DocumentType: String, Codable, CaseIterable {
    case aadhaar = "Aadhaar Card"
    case pan = "PAN Card"
    case incomeProof = "Income Proof"
}

struct Document: Identifiable, Codable {
    let id: UUID
    let type: DocumentType
    var imageData: Data?
    var isVerified: Bool
    var extractedDetails: ExtractedDetails?
    
    init(type: DocumentType, imageData: Data? = nil, isVerified: Bool = false, extractedDetails: ExtractedDetails? = nil) {
        self.id = UUID()
        self.type = type
        self.imageData = imageData
        self.isVerified = isVerified
        self.extractedDetails = extractedDetails
    }
}

struct ExtractedDetails: Codable {
    let name: String?
    let dob: String?
    let income: String?
    let employmentType: String?
    let aadhaarNumber: String?
    let panNumber: String?
    
    init(name: String? = nil, 
         dob: String? = nil, 
         income: String? = nil, 
         employmentType: String? = nil, 
         aadhaarNumber: String? = nil,
         panNumber: String? = nil) {
        self.name = name
        self.dob = dob
        self.income = income
        self.employmentType = employmentType
        self.aadhaarNumber = aadhaarNumber
        self.panNumber = panNumber
    }
}
