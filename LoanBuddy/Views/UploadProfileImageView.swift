//
//  UploadProfileImageView.swift
//  LoanBuddy
//
//  Created by user@59 on 19/03/2025.
//

import SwiftUI
import PhotosUI

struct UploadProfileImageView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Add Profile Picture")
                .font(AppStyle.TextStyle.title)
                .padding(.top, 40)
            
            Text("Please upload a profile picture to continue")
                .font(AppStyle.TextStyle.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Profile Image View
            ZStack {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppStyle.primaryColor, lineWidth: 2))
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 180, height: 180)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                }
                
                // Camera Icon overlay
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Circle()
                        .fill(AppStyle.primaryColor)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                        )
                        .offset(x: 60, y: 60)
                }
            }
            .padding(.vertical, 40)
            
            // Continue Button - only enabled when image is selected
            Button(action: {
                if let profileImage = profileImage,
                   let imageData = profileImage.jpegData(compressionQuality: 0.8) {
                    // Store the profile image
                    appState.userData.profileImage = imageData
                    
                    // Store face features for later matching
                    FaceMatchingService.shared.setProfileFace(from: profileImage)
                    
                    dismiss()
                }
            }) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(profileImage == nil) // Disable if no image selected
            .opacity(profileImage == nil ? 0.6 : 1) // Visual feedback
            .padding(.horizontal)
            
            // Gallery Button
            PhotosPicker(selection: $selectedItem, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Choose from Gallery")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
            .padding(.horizontal)
            
            Spacer()
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        self.profileImage = image
                    }
                }
            }
        }
        .interactiveDismissDisabled() // Prevent dismissal by swipe
    }
}
