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
    @State private var isLoggedIn = false
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView()
            } else if !isLoggedIn {
                LoginView(isLoggedIn: $isLoggedIn)
            } else {
                NavigationStack {
                    HomeView()
                }
            }
        }
        .environmentObject(appState)
    }
}

#Preview {
    ContentView()
}
