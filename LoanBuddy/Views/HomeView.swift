import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: LoanApplicationState
    @State private var showStartLoanFlow = false
    @State private var showingProfile = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
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
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppStyle.primaryColor)
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

// Update ProfileView to use AppStorage instead of Binding
struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    profileHeader
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
        }
    }
    
    private var profileHeader: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(AppStyle.primaryColor)
            
            VStack(alignment: .leading) {
                Text("John Doe")
                    .font(AppStyle.TextStyle.heading)
                Text("john.doe@example.com")
                    .font(AppStyle.TextStyle.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
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

#Preview {
    HomeView()
        .environmentObject(LoanApplicationState())
} 