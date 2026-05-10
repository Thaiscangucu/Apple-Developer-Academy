import SwiftUI


struct ProfilePage: View {
    @State private var tabView = 0
    private var scrollImages = [
        "Minecraft",
        "tlou",
        "gta",
        "readdead"
    ]
        
    var rectWidth: CGFloat = 90
    var rectHeight: CGFloat = 125
    
    var body: some View {
        NavigationStack{
            VStack {
                HStack{
                    Label("", systemImage: "gear")
                    Spacer()
                    Text("Username")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Label("", systemImage: "ellipsis")
                }
                Picker("", selection: $tabView) {
                    Text("Profile").tag(0)
                    Text("Diary").tag(1)
                    Text("Lists").tag(2)
                    Text("Gaming List").tag(3)
                }
                .pickerStyle(.segmented)
                ScrollView(.vertical){
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(.top)
                    
                    DividerLine(width: .infinity)
                        .padding(.top)
                        .padding(.leading)
                    
                    HStack{
                        Text("Favorites")
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.leading)
                    HStack(){
                        ForEach(scrollImages, id: \.self) { imageString in
                            Image(imageString)
                                .resizable()
                                .frame(width: rectWidth, height: rectHeight)
                                .shadow(radius: 3)
                                .cornerRadius(3)
                        }
                    }
                    DividerLine(width: .infinity)
                        .padding(.top)
                    
                    HStack{
                        Text("Recent Activity")
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.leading)
                    HStack(){
                        ForEach(scrollImages, id: \.self) { imageString in
                            VStack{
                                Image(imageString)
                                    .resizable()
                                    .frame(width: rectWidth, height: rectHeight)
                                    .shadow(radius: 3)
                                    .cornerRadius(3)
                                FiveStars()
//                                HStack(spacing: -7){
//                                    Label("", systemImage: "star.fill")
//                                    Label("", systemImage: "star.fill")
//                                    Label("", systemImage: "star.fill")
//                                    Label("", systemImage: "star.fill")
//                                    Label("", systemImage: "star.fill")
//                                }
//                                .font(.caption2)
                            }
                        }
                    }
                    DividerLine(width: .infinity)
                        .padding(.top)
                        .padding(.leading)
                    
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Text("More activity")
                            .foregroundStyle(.white)
                            .font(.title2)
                            .padding(.leading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                    }
                    DividerLine(width: .infinity)
                    HStack{
                        VStack{
                            Spacer()
                            Label("", systemImage: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.accent)
                        }
                        BarChart(borderWidth: 29)
                        VStack{
                            Spacer()
                            FiveStars()
                                .foregroundStyle(.accent)
                                .padding(.leading)
                            
                        }
                    }
                    .padding(.top)
                }
            }
        }
    }
}
