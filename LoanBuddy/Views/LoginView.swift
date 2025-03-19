import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var isAnimating = false
    @State private var navigateToUploadProfileImage = false // New state for navigation
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.white, AppStyle.backgroundColor]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Logo and Title
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
                        
                        // Login Form
                        VStack(spacing: 20) {
                            TextField("Email", text: $email)
                                .textFieldStyle(AppTextFieldStyle())
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            
                            SecureField("Password", text: $password)
                                .textFieldStyle(AppTextFieldStyle())
                                .textContentType(.password)
                            
                            Button(action: {
                                withAnimation {
                                    isLoggedIn = true
                                    navigateToUploadProfileImage = true // Redirect to upload profile image
                                }
                            }) {
                                Text("Sign In")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        // Divider
                        HStack {
                            VStack { Divider() }
                            Text("OR")
                                .foregroundColor(.secondary)
                                .font(AppStyle.TextStyle.caption)
                            VStack { Divider() }
                        }
                        .padding(.horizontal)
                        
                        // Apple Sign In
                        SignInWithAppleButton { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            switch result {
                            case .success(_):
                                withAnimation {
                                    isLoggedIn = true
                                    navigateToUploadProfileImage = true // Redirect to upload profile image
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .padding(.horizontal)
                        
                        // Google Sign In
                        Button(action: {
                            withAnimation {
                                isLoggedIn = true
                                navigateToUploadProfileImage = true // Redirect to upload profile image
                            }
                        }) {
                            HStack {
                                Image("google_logo") // Add this image to your assets
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
                        
                        // Sign Up Link
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
