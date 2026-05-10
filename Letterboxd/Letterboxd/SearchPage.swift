import SwiftUI

struct SearchPage: View {
    @State var text = ""
    var sentences: [String] = ["Realease year", "Genre", "Studio", "Platforms", "Gamemode", "Online Mutiplayer", "Players Supported", "Awards & Nominations"]
    var sentences2: [String] = ["Journal", "Podcast", "Showdown"]
    
    var body: some View {
        VStack{
            NavigationStack{
                Text("")
                    .searchable(text: $text, prompt: "Find games, characters, studio, reviews..." )
                    .padding(.top, -25)
                    .navigationTitle("Search")
                    .navigationBarTitleDisplayMode(.inline)
                
                VStack{
                    HStack{
                        Text("Browse by")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.leading, 7.0)
                        Spacer()
                    }
                    .padding(.bottom)
                    ForEach(sentences, id: \.self) { sentence in
                        NavigationLink {
                            EmptyView()
                        } label: {
                            Text("\(sentence)")
                                .padding(.leading, 4.0)
                                .foregroundStyle(.gray)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.trailing)
                            
                        }
                        DividerLine(width: .infinity)
                            
                    }
                    .padding(2)
                    .foregroundStyle(.gray)
                    
                    HStack{
                        Text("Gameboxd.com")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.leading, 7.0)
                        Spacer()
                    }
                    .padding(.top)
                    ForEach(sentences2, id: \.self) { sentence in
                        NavigationLink {
                            EmptyView()
                        } label: {
                            Text("\(sentence)")
                                .padding(.leading, 4.0)
                                .foregroundStyle(.gray)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .padding(.trailing)
                            
                        }
                        DividerLine(width: .infinity)
                    }
                    .padding(2)
                    .foregroundStyle(.gray)
                    Spacer()
                }
                .padding(.leading)
                
            }
            
            .padding(.top, -24)
            
            
        }
    }
    
}

