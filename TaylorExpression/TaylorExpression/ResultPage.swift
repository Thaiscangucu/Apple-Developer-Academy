import SwiftUI
import Foundation

import WebKit

struct YouTubeView: UIViewRepresentable {
    let videoId: String
    func makeUIView(context: Context) ->  WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let demoURL = URL(string: "https://www.youtube.com/watch?v=\(videoId)") else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: demoURL))
    }
}

struct ResultPage: View {
    
    @Binding var selectedImage: UIImage?
    @Binding var classificationLabel: String
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25)
                .foregroundColor(.white)
                .padding()
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    HStack{
                        Text("You're feeling")
                            .font(.system(size: 32))
                            .fontWeight(.light)

                        Spacer()
                    }
                    HStack{
                        Text(classificationLabel)
                            .textCase(.uppercase)
                            .font(.system(size: 80))
                            .fontWeight(.heavy)
                            .padding(.top, -35)
                        Spacer()
                    }
                    Spacer()
                    Image(uiImage: (selectedImage ?? UIImage(named: "teste"))!)
                        .resizable()
                        .frame(width:320, height: 320)
                        .scaledToFit()
                    
                
                    
                    switch (classificationLabel){
                    case "sad":
                        if let randomSadKey = sad.keys.randomElement() {
                            if let valor = sad[randomSadKey] {
                                HStack{
                                    Text("\(randomSadKey)")
                                        .font(.system(size: 32))
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                HStack{
                                    Text("Taylor Swift")
                                        .font(.system(size: 20))
                                    Spacer()
                                }
                                Text("\n\(valor)")
                                
                                    .font(.body.leading(.tight))
                            }
                        }
                    case "happy":
                        if let randomHappyKey = happy.keys.randomElement() {
                            if let valor = happy[randomHappyKey] {
                                HStack{
                                    Text("\(randomHappyKey)")
                                        .font(.system(size: 32))
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                HStack{
                                    Text("Taylor Swift")
                                        .font(.system(size: 20))
                                    Spacer()
                                }
 
                                ScrollView(showsIndicators: false) {
                                    VStack {
                                        if let lista = happy[randomHappyKey] {
                                            if lista.count > 1 {
                                                let songId = lista[1]
                                                
                                                YouTubeView(videoId: songId)
                                                    .frame(width: 380, height: 280)
                                                   
                                            }
                                        }
                                        
                                    }
                                }
                                Text("\n\(valor[0])")
                            }
                        }
                    case "fear":
                        if let randomFearKey = fear.keys.randomElement() {
                            if let valor = fear[randomFearKey] {
                                HStack{
                                    Text("\(randomFearKey)")
                                        .font(.system(size: 32))
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                HStack{
                                    Text("Taylor Swift")
                                        .font(.system(size: 20))
                                    Spacer()
                                }
//                                Image("cover")
//                                    .resizable().opacity(0.2)
//                                ScrollView(showsIndicators: false) {
//                                    VStack {
//                                        YouTubeView(videoId: ids[0])
//                                            .frame(width: 300, height: 300)
//                                            .padding()
//                                    }
//                                }
                                Text("\n\(valor)")
                            }
                        }
                    case "love":
                        if let randomLoveKey = love.keys.randomElement() {
                            if let valor = love[randomLoveKey] {
                                HStack{
                                    Text("\(randomLoveKey)")
                                        .font(.system(size: 32))
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                HStack{
                                    Text("Taylor Swift")
                                        .font(.system(size: 20))
                                    Spacer()
                                }
//                                Image("cover")
//                                    .resizable().opacity(0.2)
//                                ScrollView(showsIndicators: false) {
//                                    VStack {
//                                        YouTubeView(videoId: ids[0])
//                                            .frame(width: 300, height: 300)
//                                            .padding()
//                                    }
//                                }
                                Text("\n\(valor)")
                            }
                        }
                    case "angry":
                        if let randomAngryKey = angry.keys.randomElement() {
                            if let valor = angry[randomAngryKey] {
                                HStack{
                                    Text("\(randomAngryKey)")
                                        .font(.system(size: 32))
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                HStack{
                                    Text("Taylor Swift")
                                        .font(.system(size: 20))
                                    Spacer()
                                }
//                                Image("cover")
//                                    .resizable().opacity(0.2)
//                                ScrollView(showsIndicators: false) {
//                                    VStack {
//                                        YouTubeView(videoId: ids[0])
//                                            .frame(width: 300, height: 300)
//                                            .padding()
//                                    }
//                                }
                                Text("\n\(valor)")
                            }
                        }
                    default: Text("")
                    }
                    
                }
                .background(.white)
                .padding(32)
                .cornerRadius(25)
            }
            .padding(32)
        }
        .background(Color("vinho"))
        
    }
}

#Preview {
    ResultPage(selectedImage: .constant(UIImage(named: "teste")!), classificationLabel: .constant("happy"))
}
