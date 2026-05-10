import SwiftUI
/// A view that displays a button to get on the line.
/// - Parameter expandCards: The state that controls if the card is being expanded.
/// - Parameter isClicked: The state that controls if the sheet is showing or not.
struct ButtonEnterQueue: View {
    @State var expandCards: Bool = false
    @State var isClicked: Bool = false
    @Binding var isClicked2: Bool     
    
    var body: some View {
        Button {
            isClicked.toggle()
        } label: {
            Image (systemName: "plus")
        }
        .sheet(isPresented: $isClicked, content: {
            SheetEnterQueue(isClicked: $isClicked2)
                .presentationDetents([.height(600)])
        })
    }
}


//#Preview {
//    ButtonEnterQueue()
//}
