import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView{
            HomePage()
                .tabItem{
                    Label("", systemImage: "gamecontroller")
                }
            SearchPage()
                .tabItem{
                    Label("", systemImage: "magnifyingglass")
                }
            LogPage()
                .tabItem{
                    Label("", systemImage: "plus.circle")
                }
            ActivityPage()
                .tabItem{
                    Label("", systemImage: "bolt")
                }
            ProfilePage()
                .tabItem{
                    Label("", systemImage: "person")
                }
        }
    }
}


#Preview {
    ContentView()
}

