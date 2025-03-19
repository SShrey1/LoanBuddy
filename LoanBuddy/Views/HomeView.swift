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
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newDocument = Document(
                type: documentType,
                imageData: imageData,
                isVerified: false
            )
            
            appState.userData.documents.removeAll { $0.type == documentType }
            appState.userData.documents.append(newDocument)
            selectedDocumentType = nil
            selectedItem = nil
            isUploading = false
        }
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
