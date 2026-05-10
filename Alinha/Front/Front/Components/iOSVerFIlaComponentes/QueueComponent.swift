// Home.swift

import SwiftUI

///View for showing and refreshing the queue on iOS
/// - Parameter currentCard: The state that controls the card that is in display.
/// - Parameter isClicked: The Binding that controls if the sheet is showing or not.
/// - Parameter showingAlert: State that controls the alert when deleting a card
/// - Parameter selected: The state that controls the selected student
/// - Parameter categoryFilter: Var for filter the current category
/// - Parameter role: Var for user role filter
struct QueueComponent: View {
    @State var currentCard: GetAppointments?
    @Binding var isClicked: Bool
    @State var showingAlert = false
    @State var selected: Int = 0
    @State var filteredList: [GetAppointments]
    @Binding var cards: [GetAppointments]

    @State var categoryFilter: String
    @State var role: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // MARK: Cards
                ForEach(Array(filteredList.enumerated()), id:\.element.id) { index, appointment in
                    if selected == index {
                        Button {
                            withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 1, blendDuration: 1)) {
                                selected = 0
                            }
                        } label: {
                            CardOpenView(showingAlert: $showingAlert, cards: $cards, card: appointment, role: role, index: index, desc: appointment.description,  categoryFilter: categoryFilter)
                        }
                        .zIndex(Double(filteredList.count - index))
                    }
                    else {
                        Button {
                            withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 1, blendDuration: 1)) {
                                selected = index
                            }
                        } label: {
                            CardCloseView(showingAlert: $showingAlert, cards: $cards, card: appointment, role: role, index: index, categoryFilter: categoryFilter)
                        }
                        .zIndex(Double(filteredList.count - index))
                    }
                }
            }
            .onAppear() {
                filteredList = cards.filter{
                    $0.path == categoryFilter
                }
            }
            .onChange(of: isClicked) {
                filteredList = cards.filter{
                    $0.path == categoryFilter
                }
            }
            .onChange(of: showingAlert) {
                filteredList = cards.filter{
                    $0.path == categoryFilter
                }
            }
            Rectangle()
                .frame(height: 140)
                .foregroundStyle(.clear)
        }
    }
}
