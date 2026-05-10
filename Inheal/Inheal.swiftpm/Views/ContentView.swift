import SwiftUI

//TODO: Mostrar ícones na tab bar também
struct ContentView: View {
    @AppStorage("hasSeenOnboarding") var firstTime: Bool = true
    var body: some View {
        TabView{
            BreatheView()
                .tabItem{
                    Label("Breathe", image: "leaf")
                }
            
            DescriptionCardsView()
                .tabItem{
                    Label("Description Cards", systemImage: "leaf")
                    
                }
            HabitsView()
                .tabItem{
                    Label("Habits", systemImage: "list")
                    
                }
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $firstTime) {
            OnBoarding()
        }
        
    }
}

#Preview{
    ContentView()
}
