import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var email = ""
    @State private var name = "" // Changed from password to name
    @State private var showingSignUp = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var isAnimating = false
    @State private var navigateToUploadProfileImage = false
    @EnvironmentObject private var appState: LoanApplicationState // Added to store email and name
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.white, AppStyle.backgroundColor]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 15) {
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 70))
                                .foregroundColor(AppStyle.primaryColor)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                            
                            Text("LoanBuddy")
                                .font(AppStyle.TextStyle.title)
                            
                            Text("Your AI Loan Assistant")
                                .font(AppStyle.TextStyle.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)
                        
                        VStack(spacing: 20) {
                            TextField("Email", text: $email)
                                .textFieldStyle(AppTextFieldStyle())
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            
                            TextField("Full Name", text: $name) // Replaced SecureField with TextField
                                .textFieldStyle(AppTextFieldStyle())
                                .textContentType(.name)
                            
                            Button(action: {
                                withAnimation {
                                    // Store email and name in app state
                                    appState.userData.email = email
                                    appState.userData.name = name
                                    isLoggedIn = true
                                    navigateToUploadProfileImage = true
                                }
                            }) {
                                Text("Sign In")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            VStack { Divider() }
                            Text("OR")
                                .foregroundColor(.secondary)
                                .font(AppStyle.TextStyle.caption)
                            VStack { Divider() }
                        }
                        .padding(.horizontal)
                        
                        SignInWithAppleButton { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                withAnimation {
                                    if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                        appState.userData.email = appleIDCredential.email ?? ""
                                        if let fullName = appleIDCredential.fullName {
                                            appState.userData.name = "\(fullName.givenName ?? "") \(fullName.familyName ?? "")".trimmingCharacters(in: .whitespaces)
                                        }
                                    }
                                    isLoggedIn = true
                                    navigateToUploadProfileImage = true
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .padding(.horizontal)
                        
                        Button(action: {
                            withAnimation {
                                // Store email and name for Google sign-in
                                appState.userData.email = email
                                appState.userData.name = name
                                isLoggedIn = true
                                navigateToUploadProfileImage = true
                            }
                        }) {
                            HStack {
                                Image("google_logo")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("Sign in with Google")
                                    .font(AppStyle.TextStyle.body)
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(AppStyle.cornerRadius)
                            .shadow(color: AppStyle.shadowColor, radius: 4)
                        }
                        .padding(.horizontal)
                        
                        Button("Don't have an account? Sign Up") {
                            showingSignUp = true
                        }
                        .font(AppStyle.TextStyle.caption)
                        .foregroundColor(AppStyle.primaryColor)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .onAppear {
                isAnimating = true
            }
            .navigationDestination(isPresented: $navigateToUploadProfileImage) {
                UploadProfileImageView()
            }
        }
    }
}
