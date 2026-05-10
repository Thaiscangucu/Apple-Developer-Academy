//
//  ButtonExitQueue.swift
//  iOSFront
//
//  Created by Carolina Sun on 25/08/25.
//

import SwiftUI
/// A view that displays a button to get on the line.
/// - Parameter expandCards: The state that controls if the card is being expanded.
/// - Parameter isClicked: The state that controls if the sheet is showing or not.
struct ButtonCallNext: View {
    @Binding var showingAlert: Bool
    
    @Binding var cards: [GetAppointments]
    
    var categoryFilter: String
    var position: Int
    
    var body: some View {
        Button {
            if !cards.isEmpty {
                let filteredCards: [GetAppointments] = cards.filter{$0.type == categoryFilter}
                let firstCard: GetAppointments = filteredCards.first!
                let selectedCard: GetAppointments = filteredCards[position]
                if position == 0 {
                    if let index = cards.firstIndex(where:{ $0.id == firstCard.id}){
                        cards.remove(at: index)
                    }
                }
                else {
                    if let selectedPosition = cards.firstIndex(where:{ $0.id == selectedCard.id}){
                        cards.remove(at: selectedPosition)
                    }
                }
                showingAlert = true
            }
        } label: {
            Image(systemName: "hand.raised")
                .font(.largeTitle)
                .background(.gray)
                .clipShape(Circle())
        }
        .padding()
        .alert("Aluno Chamado", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
