//
//  CardOpenView.swift
//  teste
//
//  Created by Francisco Losada on 27/08/25.
//

// CardView.swift

import SwiftUI
/// A component for showing the student card closed
/// - Parameter showingAlert: State that controls the alert when deleting a card
/// - Parameter card: Var for selecting the card that is being showed in the view
/// - Parameter role: Var for user role filter
/// - Parameter index: The users index on the queue
/// - Parameter desc: Var for show the users problem description
/// - Parameter categoryFilter: Var for filter the current category
struct CardOpenView: View {
    @Binding var showingAlert: Bool
    @Binding var cards: [GetAppointments]

    var card: GetAppointments
    var role: Bool
    var index: Int
    var desc: String
    var categoryFilter: String
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("\(index+1).")
                        .font(.callout)
                }
                Ellipse()
                    .fill(.white)
                    .frame(width: 82.31, height: 82.31)
                    .shadow(radius: 10)
                VStack(alignment: .leading) {
                    Text(card.studentName)
                        .bold()
                        .font(.subheadline)
                    Text(card.type)
                        .font(.subheadline)
                }
                Spacer()
                if role == false {
                    ButtonCallNext(showingAlert: $showingAlert, cards: $cards, categoryFilter: categoryFilter, position: index)
                }
            }
            HStack {
                Text(desc)
                    .font(.subheadline)
            }
        }
        .foregroundStyle(.black)
        .padding()
        .frame(width: 363)
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.top, 20)
    }
}

//#Preview {
//    @State var showingAlert = false
//    CardOpenView(showingAlert: $showingAlert)
//}

