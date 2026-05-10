//
//  FuitsComponentMainButtonView.swift
//  ProximaEstacao
//
//  Created by Lucca Pivoto on 03/03/26.
//

import SwiftUI

struct NSControlerMainButtonView: View {
    let mainTxt: String
    @Binding var playersCount: [Player]
    var body: some View {
        GeometryReader{ geometry in
            Button{
                playersCount.removeFirst()
            } label: {
                ZStack(){
                    RoundedRectangle(cornerRadius: 41)
                        .frame(width: 250 , height: 110)
                        .shadow(radius: 7.3 , x: 0 , y: 4)
                        .foregroundStyle(Color("NSBackGround"))
                    NSControlViewDefaultText(text: "\(mainTxt)", textSize: 48)
                        .tint(.black)
                }
            }
            .position(CGPoint(x: geometry.size.width / 1.55 , y: geometry.size.height / 1.4))
        }
    }
}
