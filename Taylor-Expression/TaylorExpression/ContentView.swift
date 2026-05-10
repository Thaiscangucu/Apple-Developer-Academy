import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Color("vinho")
                VStack {
                    Text("Swift Expression")
                        .foregroundColor(.white)
                        .font(Font.custom("Satisfaction", size:80))
                        .bold()
                    ZStack{
                        RoundedRectangle (cornerRadius: 20)
                            .frame(width: 100, height: 50)
                            .foregroundColor(.white)
                        NavigationLink ("Start", destination: LoadingView())
                    }
                }
                .padding()
            }
            .ignoresSafeArea(.all)
        }
    }
}

#Preview {
    ContentView()
}
