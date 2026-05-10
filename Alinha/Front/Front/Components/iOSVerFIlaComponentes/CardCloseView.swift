import SwiftUI

/// A component for showing the student card closed
/// - Parameter card: Var for selecting the card that is being showed in the view
/// - Parameter role: Var for user role filter
/// - Parameter index: The users index on the queue
/// - Parameter categoryFilter: Var for filter the current category
struct CardCloseView: View {
    @Binding var showingAlert: Bool
    @Binding var cards: [GetAppointments]
    
    var card: GetAppointments
    var role: Bool
    var index: Int
    var categoryFilter: String
    
    var body: some View {
        HStack {
            VStack {
                Text("\(index+1).")
                    .font(.callout)
            }
            Ellipse()
                .fill(.white)
                .frame(width: 57.95, height: 57.95)
                .shadow(radius: 10)
            VStack(alignment: .leading) {
                Text(card.studentName)
                    .bold()
                    .font(.subheadline)
                Text(card.type)
                    .font(.subheadline)
            }
            Spacer()
            if index == 0 && role == false {
                ButtonCallNext(showingAlert: $showingAlert, cards: $cards, categoryFilter: categoryFilter, position: index)
            }
        }
        .foregroundStyle(.black)
        .padding()
        .frame(width: 305, height: 92.4)
        .background(.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
        .padding(.bottom, -20)
    }
}

//#Preview {
//    CardCloseView(role: "Mentor", index: 0)
//}
