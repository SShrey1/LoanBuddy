import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @Binding var isLoggedIn: Bool
    @State private var isAnimating = false
    
    var body: some View {
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
                    
                    // Google Sign In
                    Button(action: {
                        withAnimation {
                            isLoggedIn = true
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
            SignUpView(isLoggedIn: $isLoggedIn)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    // Handle sign up
                    isLoggedIn = true
                    dismiss()
                }) {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
} 