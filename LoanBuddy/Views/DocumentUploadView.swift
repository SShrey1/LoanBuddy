import SwiftUI
import PhotosUI

struct DocumentUploadView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedDocumentType: DocumentType?
    @State private var showingUploadAnimation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                headerCard
                
                // Documents List
                documentsSection
                
                // Navigation Buttons
                navigationButtons
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(AppStyle.backgroundColor)
        .overlay {
            if showingUploadAnimation {
                uploadingOverlay
            }
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Required Documents")
                .font(AppStyle.TextStyle.heading)
            
            Text("Please upload clear photos of the following documents")
                .font(AppStyle.TextStyle.body)
                .foregroundColor(.secondary)
            
            documentProgressBar
        }
        .padding()
        .background(AppStyle.CardStyle.shadow)
    }
    
    private var documentProgressBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(appState.userData.documents.count)/\(DocumentType.allCases.count) Uploaded")
                    .font(AppStyle.TextStyle.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int((Float(appState.userData.documents.count) / Float(DocumentType.allCases.count)) * 100))%")
                    .font(AppStyle.TextStyle.caption)
                    .foregroundColor(AppStyle.primaryColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(AppStyle.primaryColor)
                        .frame(width: geometry.size.width * CGFloat(appState.userData.documents.count) / CGFloat(DocumentType.allCases.count), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding(.top, 8)
    }
    
    private var documentsSection: some View {
        VStack(spacing: 16) {
            ForEach(DocumentType.allCases, id: \.self) { documentType in
                documentCard(for: documentType)
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
                
                Text(documentType.rawValue)
                    .font(AppStyle.TextStyle.body)
                
                Spacer()
                
                if document?.isVerified == true {
                    Text("Verified")
                        .font(AppStyle.TextStyle.caption)
                        .foregroundColor(.green)
                }
            }
            
            if document == nil {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Upload Document")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(AppStyle.primaryColor)
                    .cornerRadius(AppStyle.cornerRadius)
                }
                .onChange(of: selectedItem) { _ in
                    selectedDocumentType = documentType
                    uploadDocument()
                }
            }
        }
        .padding()
        .background(AppStyle.CardStyle.shadow)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            Button("Back") {
                withAnimation {
                    appState.currentStep = .incomeVerification
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            
            if isAllDocumentsUploaded {
                Button("Continue") {
                    withAnimation {
                        appState.currentStep = .result
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(.top)
    }
    
    private var uploadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Uploading Document...")
                    .font(AppStyle.TextStyle.body)
                    .foregroundColor(.white)
            }
        }
    }
    
    private var isAllDocumentsUploaded: Bool {
        appState.userData.documents.count == DocumentType.allCases.count
    }
    
    private func uploadDocument() {
        guard let documentType = selectedDocumentType else { return }
        
        showingUploadAnimation = true
        
        // Simulate upload delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let newDocument = Document(
                type: documentType,
                imageURL: URL(string: "https://example.com/dummy.jpg"),
                isVerified: true
            )
            
            appState.userData.documents.removeAll { $0.type == documentType }
            appState.userData.documents.append(newDocument)
            
            showingUploadAnimation = false
            selectedItem = nil
        }
    }
} 