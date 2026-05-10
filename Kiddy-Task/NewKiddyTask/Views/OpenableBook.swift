//
//  ContentView.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//

import SwiftUI

struct ContentView2: View {
    @State var progress: CGFloat = 0
    var body: some View {
        NavigationStack{
            VStack{
                OpenableBookView(config: .init(progress: progress)) { size in
                    FrontView(size)
                } insideLeft: { size in
                    LeftView()
                } insideRight: { size in
                    RightView()
                }
                .onTapGesture {
                    withAnimation(.snappy){
                        progress = (progress == 1.0 ? 0.0 : 1.0)
                    }
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    func FrontView(_ size: CGSize) -> some View {
        Image(.book)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .offset(y: 10)
    }
    @ViewBuilder
    func LeftView() -> some View {
        Image(.bookPage2)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    func RightView() -> some View {
        Image(.bookPage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct OpenableBookView<Front: View, InsideLeft: View, InsideRight: View> : View{
    
    var config: Config = .init()
    @ViewBuilder var front: (CGSize) -> Front
    @ViewBuilder var insideLeft: (CGSize) -> InsideLeft
    @ViewBuilder var insideRight: (CGSize) -> InsideRight
    
    var body: some View{
        GeometryReader{
            let size = $0.size
            let progress = max(min(config.progress, 1), 0)
            let rotation = progress * -180
            let cornerRadius = config.cornerRadius
            let shadowColor = config.shadowColor
            
            ZStack{
                insideRight(size)
                    .frame(width: size.width, height: size.height)
                    .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: cornerRadius, topTrailingRadius: cornerRadius))
                    .shadow(color: shadowColor.opacity(0.1 * progress), radius: 5, x: 5, y: 5)
                
                front(size)
                    .frame(width: size.width, height: size.height)
                    .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: cornerRadius, topTrailingRadius: cornerRadius))
                    .shadow(color: shadowColor.opacity(0.1), radius: 5, x: 5, y: 5)
                
                    .allowsHitTesting(-rotation < 90)
                    .overlay{
                        if -rotation > 90 {
                            insideLeft(size)
                                .frame(width: size.width, height: size.height)
                                .scaleEffect(x: -1)
                                .transition(.identity)
                        }
                    }
                    .offset(x: -rotation > 90 ? -12: 0)
                    .rotation3DEffect(
                        .init(degrees: rotation),
                        axis: (x: 0.0, y: 1.0, z: 0.0),
                        anchor: .leading,
                        perspective: 0.3
                    )
            }
            .offset(x: (config.width / 2) * progress)
        }
        .frame(width: config.width, height: config.height)
    }
    
    struct Config{
        var width: CGFloat = 150
        var height: CGFloat = 200
        var progress: CGFloat = 0
        var cornerRadius: CGFloat = 10
        var shadowColor: Color = .black
    }
}

#Preview {
    ContentView2()
}
