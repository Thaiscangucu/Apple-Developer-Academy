//
//  File.swift
//  Inheal
//
//  Created by Thais Cangucu on 21/01/26.
//

import SwiftUI
struct QuizCard: View{
    var question: String
    @State var answer: String = ""
    var body: some View{
        ZStack(alignment: .top) {
            
            RoundedRectangle(cornerRadius: 49)
                .foregroundStyle(.white.opacity(0.7))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 49))
            
            VStack(alignment: .leading) {
                Text(question)
                    .bold()
                    .font(.title2)
                    .padding(.bottom, 5)
                
                ZStack(alignment: .topLeading) {
                    
                    if answer.isEmpty {
                        Text("Type your answer here...")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
                    }
                    
                    
                    TextEditor(text: $answer)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .foregroundStyle(.primary)
                }
            }
            .padding(30)
        }
        .frame(width: 700, height: 500)
    }
}

