import SwiftUI

struct Games : View {
    private var scrollImages: [String] = [
        "Minecraft",
        "tlou",
        "gta",
        "readdead"
    ]
    var rectWidth: CGFloat = 125
    var rectHeight: CGFloat = 175
    
    var body: some View {
        ScrollView(.vertical){
            
            ZStack{
                Rectangle()
                    .frame(width: .infinity, height: 82)
                    .foregroundStyle(Color.darkgray)
                
                HStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 46, height: 18)
                            .padding()
                            .foregroundStyle(.green)
                        
                        Text("PRO")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .bold()
                    }
                    Text("Remove ads, add profile stats, activity and service filters, favorite streaming services and more by upgrading to Pro.")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            }
            HStack{
                NavigationLink {
                    EmptyView()
                } label: {
                    Text("Popular this week")
                        .foregroundStyle(.white)
                        .font(Font.custom("Silkscreen-Regular", size: 20))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 20){
                    ForEach(scrollImages, id: \.self) { imageString in
                        NavigationLink {
                            GameTab()
                        }
                        label: {
                            Image(imageString)
                                .resizable()
                                .frame(width: rectWidth, height: rectHeight)
                                .shadow(radius: 3)
                                .cornerRadius(3)
                        }
                    }
                }
                
            }
            HStack{
                NavigationLink {
                    EmptyView()
                } label: {
                    Text("New from friends")
                        .foregroundStyle(.white)
                        .font(Font.custom("Silkscreen-Regular", size: 20))
                
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                }
            }
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 20){
                    
                    ForEach(scrollImages, id: \.self){imageString in
                        
                        VStack{
                            NavigationLink{
                                GameTab()
                            }
                            label:{
                                Image(imageString)
                                    .resizable()
                                    .frame(width: rectWidth, height: rectHeight)
                                    .shadow(radius: 3)
                                    .cornerRadius(3)
                            }
                            
                            HStack(spacing: -5){
                                
                                Label("",  systemImage: "person.circle.fill")
                                    .font(.title)
                                
                                VStack{
                                    Text("username")
                                    
                                    HStack(spacing: -7){
                                        Label("", systemImage: "star.fill")
                                        Label("", systemImage: "star.fill")
                                        Label("", systemImage: "star.fill")
                                        Label("", systemImage: "star.fill")
                                        Label("", systemImage: "star.fill")
                                        
                                    }
                                    .font(.caption2)
                                    
                                }
                            }
                            .foregroundStyle(.gray)
                        }
                    }
                    
                }
                Spacer()
                
            }
            HStack{
                NavigationLink {
                    EmptyView()
                }
                label: {
                    Text("Popular with friends")
                        .foregroundStyle(.white)
                        .font(Font.custom("Silkscreen-Regular", size: 20))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 20){
                    ForEach(scrollImages, id: \.self) { imageString in
                        NavigationLink{
                            GameTab()
                        } label: {
                            Image(imageString)
                                .resizable()
                                .frame(width: rectWidth, height: rectHeight)
                                .shadow(radius: 3)
                                .cornerRadius(3)
                        }
                    }
                }
                
            }
            .padding()
        }
    }
}

