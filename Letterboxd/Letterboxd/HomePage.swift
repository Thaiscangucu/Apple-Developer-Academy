import SwiftUI

struct HomePage: View {
    
    private var stars: [String] = ["star.fill"]
    
    @State private var tabView = 0
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Gameboxd")
                    .font(Font.custom("Silkscreen-Bold", size: 35))
                    .fontWeight(.bold)
                Picker("", selection: $tabView) {
                    Text("Games").tag(0)
                    Text("Reviews").tag(1)
                    Text("Lists").tag(2)
                    Text("Journal").tag(3)
                }
                .pickerStyle(.segmented)

            }
//            .padding(.horizontal)
            if tabView == 0 {
                Games()
            }
            
            if tabView == 1{
                Reviews()
            }
            
            if tabView == 2{
                //Lists()
            }
            if tabView == 3{
                //Journal()
            }
        }
    }
}

#Preview {
    HomePage()
}
