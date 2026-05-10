//
//  DescriptionCardsView.swift
//  Inheal
//
//  Created by Thais Cangucu on 16/01/26.
//

import SwiftUI

struct DescriptionCardsView: View {
    var questions: [String] = [
        "Name and describe 5 things you see",
        "Name 4 things you can touch around you.",
        "Name 3 things you can hear",
        "Name 2 things you can smell",
        "Name 1 thing you can taste. What does the inside of your mouth taste like?",
        "Where are you right now?",
    ]
    
    // 1. Track the active question for the ScrollView and the dots
    @State private var activeQuestion: String?
    @State private var currentIndex: Int = 0
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        ZStack {
            Background()
            
            VStack(spacing: 0) {
                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        ForEach(questions, id: \.self) { question in
                            QuizCard(question: question)
                                .containerRelativeFrame(.horizontal)
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.4)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.7)
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                
                .safeAreaPadding(.horizontal, 40)
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .scrollPosition(id: $activeQuestion)
                .onChange(of: activeQuestion) { _, newValue in
                    if let newValue, let index = questions.firstIndex(of: newValue) {
                        withAnimation(.spring()) {
                            currentIndex = index
                        }
                    }
                }
                .onAppear {
                    activeQuestion = questions.first
                }
                HStack(spacing: 10) {
                    ForEach(0..<questions.count, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.white : Color.white.opacity(0.5))
                            .frame(width: currentIndex == index ? 15 : 7, height: currentIndex == index ? 10 : 7)
                            .onTapGesture {
                                // Manual control: tap a dot to scroll
                                withAnimation(.spring()) {
                                    activeQuestion = questions[index]
                                }
                            }
                    }
                }
                .background{
                    RoundedRectangle(cornerRadius: 90)
                        .frame(width: 150, height: 45)
                        .glassEffect()
                }
                .padding(.vertical, 50)
            }
        }
        
        .preferredColorScheme(.light)
    }
}
