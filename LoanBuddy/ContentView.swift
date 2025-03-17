//
//  ContentView.swift
//  LoanBuddy
//
//  Created by user@59 on 17/03/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = LoanApplicationState()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
            } else if !isLoggedIn {
                LoginView()
            } else {
                NavigationStack {
                    HomeView()
                }
            }
        }
        .environmentObject(appState)
        // Add this for testing - remove in production
        .onAppear {
            // Reset onboarding state for testing
            UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        }
    }
}

#Preview {
    ContentView()
}
