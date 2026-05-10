//
//  ContentView.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 14/07/25.

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some View {
        if hasSeenOnboarding {
            TabView{
                HomePage()
                    .tabItem{
                        Label("", systemImage: "house")
                    }
                ProgressPage()
                    .tabItem{
                        Label("", systemImage: "chart.bar.fill")
                    }
            }
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
