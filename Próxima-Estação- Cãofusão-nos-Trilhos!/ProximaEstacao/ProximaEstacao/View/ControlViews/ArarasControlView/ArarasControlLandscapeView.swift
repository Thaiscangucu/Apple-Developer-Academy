//
//  JoyStickLandscape.swift
//  ProximaEstacao
//
//  Created by Lucca Pivoto on 02/03/26.
//
import Foundation
import SwiftUI

struct ArarasControlLandscapeView: View{
    @Binding var player: Arara
    var body: some View{
        ZStack(){
            Color("NSBackGround")
            GeometryReader{ geometry in
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: geometry.size.width / 1.15 , height: geometry.size.height / 1.2)
                    .position(CGPoint(x: geometry.size.width / 2.1 , y: geometry.size.height / 2))
                    .foregroundStyle(Color("NSLightBackgroundColor"))
                CoinsFruitsComponentView(nOfCoins: player.nOfCoins, nOfFruits: player.fruta)
                NSDefaultImageView(nOfGuarana: player.qntGuarana, nOfPitanga: player.qntdPitanga, nOfCaju: player.qntCaju)
            }
            .onAppear(){
                player.setTotalOfFruits()
            }
        }
        .ignoresSafeArea()
    }
}
