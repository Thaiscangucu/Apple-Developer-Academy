//
//  Coins&MoneyComponentView.swift
//  ProximaEstacao
//
//  Created by Lucca Pivoto on 03/03/26.
//
import Foundation
import SwiftUI

struct CoinsFruitsComponentView: View{
    var nOfCoins: Int
    var nOfFruits: Int
    var body: some View{
        GeometryReader{ geometry in
            RoundedRectangle(cornerRadius: 23)
                .frame(width: geometry.size.width / 3.7 , height: geometry.size.height / 10)
                .position(CGPoint(x: geometry.size.width / 5 , y: geometry.size.height / 3.7))
                    .foregroundStyle(Color("NSInsideComponents"))
            HStack(){
                Image("Coins")
                    .resizable()
                    .frame(width: 26 , height: 26)
                    .scaledToFit()
                NSControlViewDefaultText(text: "\(nOfCoins),00", textSize: 16)
                Image("Basket")
                    .resizable()
                    .frame(width: 26 , height: 26)
                    .scaledToFit()
                    .padding(.leading , 8)
                NSControlViewDefaultText(text: "\(nOfFruits)un", textSize: 16)
            }
            .position(CGPoint(x: geometry.size.width / 5.4 , y: geometry.size.height / 3.7))
        }
        .ignoresSafeArea()
    }
}
