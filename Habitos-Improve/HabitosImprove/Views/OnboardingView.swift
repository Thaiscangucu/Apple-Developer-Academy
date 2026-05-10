//
//  OnboardingView.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 14/07/25.
//

import SwiftUI

// MARK: - Onboarding Data Model
enum OnboardingData: CaseIterable {
    case welcome, pixels, streak, progress
    
    var title: LocalizedStringKey {
        switch self {
        case .welcome: return "The first step"
        case .pixels:  return "Paint your days"
        case .streak:  return "Don't break the chain"
        case .progress: return "Your evolution"
        }
    }
    
    var description: LocalizedStringKey {
        switch self {
        case .welcome: return "Create personalized habits and adjust your routine as you like."
        case .pixels:  return "Each completed habit becomes a colored pixel on your calendar."
        case .streak:  return "Keep your streak on and watch your flame grow every day."
        case .progress: return "Follow detailed statistics of all your new habits."
        }
    }
    
    var icon: String {
        switch self {
        case .welcome: return "plus.circle.fill"
        case .pixels:  return "square.grid.3x3.fill"
        case .streak:  return "flame.fill"
        case .progress: return "chart.bar.xaxis"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .welcome: return .blue
        case .pixels:  return .verde2
        case .streak:  return .orange
        case .progress: return .green
        }
    }
}

// MARK: - View Components
struct OnboardingStepView: View {
    let data: OnboardingData
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: data.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .foregroundColor(data.iconColor)
                .shadow(color: data.iconColor.opacity(0.3), radius: 10, x: 0, y: 10)
            
            VStack(spacing: 15) {
                Text(data.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text(data.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.text)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            Background()
            
            TabView {
                ForEach(OnboardingData.allCases, id: \.self) { step in
                    OnboardingStepView(data: step)
                }
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                    
                    VStack(spacing: 10) {
                        Text("All set!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                        Text("Your journey to better habits begins now.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        finishOnboarding()
                    }) {
                        Text("Start now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accent)
                            .cornerRadius(15)
                            .padding(.horizontal, 50)
                    }
                    .padding(.bottom, 60)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
    
    // MARK: - Functions
    
    /// Updates the onboarding status to true with a spring animation.
    func finishOnboarding() {
        withAnimation(.spring()) {
            hasSeenOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
}
