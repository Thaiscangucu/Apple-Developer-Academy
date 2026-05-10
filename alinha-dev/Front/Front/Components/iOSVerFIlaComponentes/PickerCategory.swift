import SwiftUI
/// View PickerCategory that shows the different categories
/// - Parameter category: Status that shows the category
/// - Parameter isClicked: Status that shows whether a card has been clicked or not
/// - Parameter cards: Variable that receives the list of cards
/// - Parameter student: Boolean that shows whether you are a student or mentor/administrator
struct PickerCategory: View {
    @State private var category = 0
    @State var isClicked: Bool = false
    
    @Binding var path: NavigationPath
    
    
    @Binding var cards: [GetAppointments]
    var student: Bool
    
    var body: some View {
        ZStack{
            VStack{
                Picker("Category", selection: $category) {
                    Text("code").tag(0)
                    Text("design").tag(1)
                    Text("undefined").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if category == 0 {
                    QueueComponent(isClicked: $isClicked, filteredList: [], cards: $cards, categoryFilter: "code", role: student)
                }
                else if category == 1 {
                    QueueComponent(isClicked: $isClicked, filteredList: [], cards: $cards, categoryFilter: "design", role: student)
                }
                else if category == 2 {
                    QueueComponent(isClicked: $isClicked, filteredList: [], cards: $cards, categoryFilter: "undefined", role: student)
                }
            }
            
            if student {
                PositionStudent()
            }
            else {
                DisponibilityMentor()
                    .ignoresSafeArea()
            }
        }
        .toolbar {
            
            ToolbarItem(placement: .navigation) {
                ProfileButton(path: $path)
            }
            
            ToolbarItem(placement: .principal) {
                Text("Academy | Mackenzie")
            }
            if student {
                ToolbarItem(placement: .topBarTrailing) {
                    ButtonEnterQueue(isClicked2: $isClicked)
                }
            }
        }
        
    }
}

