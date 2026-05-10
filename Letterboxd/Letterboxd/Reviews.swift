import SwiftUI

struct Reviews : View {
    private var scrollImages: [String] = [
        "Minecraft",
        "tlou",
        "gta",
        "readdead"
    ]
    var body: some View {
        ScrollView(.vertical){
            VStack{
                HStack{
                    Text("New from friends")
                        .foregroundStyle(.white)
                        .font(Font.custom("Silkscreen-Regular", size: 20))
                        .padding(.top)
                    Spacer()
                }
                
                HStack{
                    Text("The Last Of Us")
                        .bold()
                    Text("2013")
                        .font(.caption)
                        .padding(.trailing)
                    Spacer()
                    Text("username")
                        .bold()
                        .padding(.leading)
                        .foregroundStyle(.otherGray)
                    Label("", systemImage: "person.circle.fill")
                        .font(.largeTitle)
                }
                .padding(.top)
                .foregroundStyle(.gray)
                HStack{
                    FiveStars()
                        .foregroundStyle(.accent)
                    Spacer()
                }
//                    .padding(.leading, -200)
                
                HStack{
                    Image("tlou")
                        .resizable()
                        .frame(width: 70, height: 100)
                        .shadow(radius: 3)
                        .border(.gray)
                        .cornerRadius(3)
                    Text("Best game ever played.")
                        .bold()
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .padding(.top)
                
                DividerLine(width: .infinity)
                
                HStack{
                    Text("Minecraft")
                        .bold()
                    Text("2009")
                        .font(.caption)
                        .padding(.trailing)
                    Spacer()
                    Text("username")
                        .bold()
                        .padding(.leading)
                        .foregroundStyle(.otherGray)
                    Label("", systemImage: "person.circle.fill")
                        .font(.largeTitle)
                }
                
                .foregroundStyle(.gray)
                
                HStack(spacing: -7){
                    Label("", systemImage: "star.fill")
                    Label("", systemImage: "star.fill")
                    Label("", systemImage: "star.fill")
                    Label("", systemImage: "star.fill")
                    
                    Spacer()
                    
                }
                .foregroundStyle(.accent)
                .font(.caption2)
                HStack{
                    Image("Minecraft")
                        .resizable()
                        .frame(width: 70, height: 100)
                        .shadow(radius: 3)
                        .border(.gray)
                        .cornerRadius(3)
                    Text("Very good game.")
                        .bold()
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .padding(.top)
                
                DividerLine(width: .infinity)
                
                ZStack{
                    Rectangle()
                        .frame(width: 360, height:360)
                        .foregroundStyle(.gray)
                    VStack{
                        Text("ANÚNCIO")
                        Text("ME DA DINHEIRO")
                    }
                }
                .padding(.top)
                
            }
        }
    }
}

