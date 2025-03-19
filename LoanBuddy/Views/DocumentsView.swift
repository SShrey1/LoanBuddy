import SwiftUI

struct DocumentsView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @State private var selectedImage: UIImage?
    @State private var showingFullScreenImage = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(DocumentType.allCases, id: \.self) { documentType in
                    if let document = appState.userData.documents.first(where: { $0.type == documentType }),
                       document.isVerified,
                       let imageData = document.imageData,
                       let uiImage = UIImage(data: imageData) {
                        documentCard(type: documentType, image: uiImage)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("My Documents")
        .fullScreenCover(isPresented: $showingFullScreenImage) {
            if let image = selectedImage {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                showingFullScreenImage = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func documentCard(type: DocumentType, image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(type.rawValue)
                //.font(AppStyle.TextStyle.title3)
                .padding(.horizontal)
            
            Button(action: {
                selectedImage = image
                showingFullScreenImage = true
            }) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: AppStyle.cornerRadius))
                    .shadow(radius: 2)
            }
        }
        .padding(.vertical, 8)
        .background(AppStyle.CardStyle.shadow)
    }
} 
