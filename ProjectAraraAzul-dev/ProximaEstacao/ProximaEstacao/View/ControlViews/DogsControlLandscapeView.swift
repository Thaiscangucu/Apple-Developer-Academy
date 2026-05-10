//
//  DogControlMainView.swift
//  ProximaEstacao
//
//  Created by Lucca Pivoto on 04/03/26.
//

import SwiftUI
import Foundation

struct DogsControlLandscapeView: View {
//    @Binding var player: Cachorro
    @State var playerRange: [Player] = [Arara() , Arara() , Arara()] // this list is only for tests
    var body: some View {
            ZStack(){
                Color("NSBackGround")
                GeometryReader{ geometry in
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: geometry.size.width / 1.15 , height: geometry.size.height / 1.2)
                        .position(CGPoint(x: geometry.size.width / 2.1 , y: geometry.size.height / 2))
                        .foregroundStyle(Color("NSLightBackgroundColor"))
                    NSControlerMainButtonView(mainTxt: "PEGAR", playersCount: $playerRange)
                    AllArarasShowView(playersRange: $playerRange)
                }
            }
            .ignoresSafeArea()
        }
}

