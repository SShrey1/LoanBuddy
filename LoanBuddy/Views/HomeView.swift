import SwiftUI
import PhotosUI
import Vision

struct HomeView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @State private var showStartLoanFlow = false
    @State private var showingProfile = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var isUploading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                headerView
                
                // Quick Actions
                quickActionsView
                
                // Application Status
                if !appState.userData.applicationStatus.rawValue.isEmpty {
                    applicationStatusView
                }
                
                // Document Upload Section
                DocumentUploadSection()
                
                // Recent Activity
                recentActivityView
                
                Spacer(minLength: 50)
            }
            .padding(.top)
        }
        .background(AppStyle.backgroundColor)
        .sheet(isPresented: $showStartLoanFlow) {
            MainNavigationView()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome Back!")
                    .font(AppStyle.TextStyle.title)
                
                Text("Start your loan journey")
                    .font(AppStyle.TextStyle.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showingProfile = true
            }) {
                if let profileImageData = appState.userData.profileImage,
                   let uiImage = UIImage(data: profileImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppStyle.primaryColor, lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppStyle.primaryColor)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var quickActionsView: some View {
        VStack(spacing: 16) {
            Button(action: {
                showStartLoanFlow = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("New Loan Application")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            
            HStack(spacing: 12) {
                quickActionButton(
                    icon: "doc.text.fill",
                    title: "Documents",
                    action: { /* Handle action */ }
                )
                
                quickActionButton(
                    icon: "chart.bar.fill",
                    title: "Track Status",
                    action: { /* Handle action */ }
                )
            }
        }
        .padding(.horizontal)
    }
    
    private func quickActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(AppStyle.TextStyle.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(SecondaryButtonStyle())
    }
    
    private var applicationStatusView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Application")
                .font(AppStyle.TextStyle.heading)
            
            ApplicationStatusCard(status: appState.userData.applicationStatus)
        }
        .padding(.horizontal)
    }
    
    private var recentActivityView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(AppStyle.TextStyle.heading)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<3) { _ in
                        activityCard
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var activityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(AppStyle.primaryColor)
                Text("Status Update")
                    .font(AppStyle.TextStyle.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("Document verification completed")
                .font(AppStyle.TextStyle.body)
            
            Text("2 hours ago")
                .font(AppStyle.TextStyle.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 200)
        .background(AppStyle.CardStyle.shadow)
    }
}

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @EnvironmentObject private var appState: LoanApplicationState
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingLanguageSelection = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    profileHeader
                }
                
                Section("Preferences") {
                    Button(action: {
                        showingLanguageSelection = true
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(AppStyle.primaryColor)
                            Text("Language")
                            Spacer()
                            Text(appState.userData.selectedLanguage.rawValue)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Account") {
                    profileRow(icon: "person.fill", title: "Personal Information")
                    profileRow(icon: "doc.fill", title: "Documents")
                    profileRow(icon: "bell.fill", title: "Notifications")
                }
                
                Section {
                    Button(action: {
                        isLoggedIn = false
                        dismiss()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingLanguageSelection) {
                LanguageSelectionView()
            }
        }
    }
    
    private var profileHeader: some View {
        HStack {
            // Profile Image with PhotosPicker
            PhotosPicker(selection: $selectedItem, matching: .images) {
                if let profileImageData = appState.userData.profileImage,
                   let uiImage = UIImage(data: profileImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppStyle.primaryColor, lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading) {
                Text(appState.userData.name.isEmpty ? "User" : appState.userData.name)
                    .font(AppStyle.TextStyle.heading)
                Text(appState.userData.email.isEmpty ? "email@example.com" : appState.userData.email)
                    .font(AppStyle.TextStyle.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .onChange(of: selectedItem) { newItem in
            Task {
                do {
                    if let data = try await newItem?.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            appState.userData.profileImage = data
                        }
                    }
                } catch {
                    print("Error loading image: \(error)")
                    // Show error alert to user
                }
            }
        }
    }
    
    private func profileRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppStyle.primaryColor)
            Text(title)
        }
    }
}

// Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Application Status Card Component
struct ApplicationStatusCard: View {
    let status: ApplicationStatus
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Current Application")
                .font(.headline)
            
            HStack {
                Text(status.rawValue)
                    .foregroundColor(statusColor)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
            }
            .padding()
            .background(statusColor.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    private var statusColor: Color {
        switch status {
        case .approved: return .green
        case .rejected: return .red
        case .needsMoreInfo: return .orange
        case .inProgress: return .blue
        case .notStarted: return .gray
        }
    }
}

struct DocumentUploadSection: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedDocumentType: DocumentType?
    @State private var showingCamera = false
    @State private var showingUploadOptions = false
    @State private var isUploading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Documents")
                .font(AppStyle.TextStyle.heading)
            
            ForEach(DocumentType.allCases, id: \.self) { documentType in
                documentCard(for: documentType)
            }
        }
        .padding(.horizontal)
        .confirmationDialog(
            "Choose Upload Method",
            isPresented: $showingUploadOptions,
            titleVisibility: .visible
        ) {
            Button("Take Photo") {
                showingCamera = true
            }
            
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Choose from Gallery")
            }
        }
        .overlay {
            if isUploading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        VStack {
                            ProgressView()
                                .tint(.white)
                            Text("Uploading...")
                                .foregroundColor(.white)
                                .padding(.top)
                        }
                    }
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { capturedImage in
                if let documentType = selectedDocumentType {
                    if let imageData = capturedImage.jpegData(compressionQuality: 0.8) {
                        handleDocumentUpload(documentType: documentType, imageData: imageData)
                    }
                }
                showingCamera = false
            }
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                do {
                    if let data = try await newItem?.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            if let documentType = selectedDocumentType {
                                handleDocumentUpload(documentType: documentType, imageData: data)
                            }
                        }
                    }
                } catch {
                    print("Error loading image: \(error)")
                    // Show error alert to user
                }
            }
        }
    }
    
    private func documentCard(for documentType: DocumentType) -> some View {
        let document = appState.userData.documents.first { $0.type == documentType }
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: document?.isVerified == true ? "checkmark.circle.fill" : "doc.fill")
                    .foregroundColor(document?.isVerified == true ? .green : AppStyle.primaryColor)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(documentType.rawValue)
                        .font(AppStyle.TextStyle.body)
                    
                    if document?.isVerified == true {
                        Text("Verified")
                            .font(AppStyle.TextStyle.caption)
                            .foregroundColor(.green)
                    } else {
                        Text(document == nil ? "Not uploaded" : "Pending verification")
                            .font(AppStyle.TextStyle.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    selectedDocumentType = documentType
                    showingUploadOptions = true
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppStyle.primaryColor)
                }
            }
            
            if let document = document, let imageData = document.imageData {
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: AppStyle.cornerRadius))
                }
            }
        }
        .padding()
        .background(AppStyle.CardStyle.shadow)
    }
    
    private func handleDocumentUpload(documentType: DocumentType, imageData: Data) {
        isUploading = true
        
        // Save image to documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "\(documentType.rawValue)_\(UUID().uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            
            if let image = UIImage(data: imageData) {
                switch documentType {
                case .aadhaar:
                    // Use Vision framework for Aadhaar card
                    verifyAadhaarCard(image: image) { aadhaarNumber in
                        handleVerificationResult(documentType: documentType, imageData: imageData, 
                                              isVerified: aadhaarNumber != nil,
                                              extractedDetails: ExtractedDetails(aadhaarNumber: aadhaarNumber))
                    }
                case .pan:
                    // Use Vision framework for PAN card
                    verifyPANCard(image: image) { panNumber in
                        handleVerificationResult(documentType: documentType, imageData: imageData, 
                                              isVerified: panNumber != nil,
                                              extractedDetails: ExtractedDetails(panNumber: panNumber))
                    }
                default:
                    // Handle other documents
                    handleVerificationResult(documentType: documentType, imageData: imageData, 
                                          isVerified: false, extractedDetails: nil)
                }
            }
        } catch {
            print("Error saving document: \(error)")
            isUploading = false
        }
    }
    
    // Add helper function to handle verification result
    private func handleVerificationResult(documentType: DocumentType, imageData: Data, 
                                        isVerified: Bool, extractedDetails: ExtractedDetails?) {
        DispatchQueue.main.async {
            let newDocument = Document(
                type: documentType,
                imageData: imageData,
                isVerified: isVerified,
                extractedDetails: extractedDetails
            )
            appState.userData.documents.removeAll { $0.type == documentType }
            appState.userData.documents.append(newDocument)
            selectedDocumentType = nil
            selectedItem = nil
            isUploading = false
        }
    }
    
    // Add this helper function for Aadhaar verification
    private func verifyAadhaarCard(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // Look for 12-digit Aadhaar number pattern
            let aadhaarPattern = "\\b\\d{4}\\s*\\d{4}\\s*\\d{4}\\b"
            
            for observation in observations {
                let recognizedText = observation.topCandidates(1).first?.string ?? ""
                if let range = recognizedText.range(of: aadhaarPattern, options: .regularExpression) {
                    let aadhaarNumber = String(recognizedText[range]).replacingOccurrences(of: " ", with: "")
                    completion(aadhaarNumber)
                    return
                }
            }
            completion(nil)
        }
        
        request.recognitionLevel = .accurate
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing OCR: \(error)")
            completion(nil)
        }
    }
    
    // Add this helper function for PAN verification
    private func verifyPANCard(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // Look for PAN card pattern: 5 letters + 4 numbers + 1 letter
            let panPattern = "\\b[A-Z]{5}[0-9]{4}[A-Z]{1}\\b"
            
            for observation in observations {
                let recognizedText = observation.topCandidates(1).first?.string ?? ""
                if let range = recognizedText.range(of: panPattern, options: .regularExpression) {
                    let panNumber = String(recognizedText[range])
                    // Verify PAN format
                    if isPANValid(panNumber) {
                        completion(panNumber)
                        return
                    }
                }
            }
            completion(nil)
        }
        
        request.recognitionLevel = .accurate
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing OCR: \(error)")
            completion(nil)
        }
    }
    
    // Add helper function to validate PAN format
    private func isPANValid(_ pan: String) -> Bool {
        let panRegex = "^[A-Z]{5}[0-9]{4}[A-Z]$"
        let panTest = NSPredicate(format: "SELF MATCHES %@", panRegex)
        return panTest.evaluate(with: pan)
    }
}

extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch {
            print("Invalid regex: \(error)")
            return []
        }
    }
}
