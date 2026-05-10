//
//  FruitsViewComponent.swift
//  ProximaEstacao
//
//  Created by Lucca Pivoto on 03/03/26.
//

import SwiftUI

struct NSDefaultImageView: View {
    var nOfGuarana: Int
    var nOfPitanga: Int
    var nOfCaju: Int
    let smalTxtSize: CGFloat = 16
    var body: some View {
        GeometryReader{ geometry in
            RoundedRectangle(cornerRadius: 21)
                .frame(width: geometry.size.width / 2 , height: geometry.size.height / 4.5)
                .position(CGPoint(x: geometry.size.width / 1.6  , y: geometry.size.height / 3.2))
                .foregroundStyle(Color("NSInsideComponents"))
            HStack(spacing: 20){
                NSDefalutImageView(imageName: "Guarana", frameWidth: 140, frameHeight: 140)
                    .padding(.bottom , 16)
                NSDefalutImageView(imageName: "Caju", frameWidth: 100, frameHeight: 110)
                    .padding(.bottom , 8)
                NSDefalutImageView(imageName: "Pitanga", frameWidth: 130, frameHeight: 130)
                    .padding(.bottom , 24)
            }
            .position(CGPoint(x: geometry.size.width / 1.58 , y: geometry.size.height / 3.2))
            HStack(spacing: 72){
                NSControlViewDefaultText(text: "\(nOfGuarana)un", textSize: smalTxtSize)
                NSControlViewDefaultText(text: "\(nOfCaju)un", textSize: smalTxtSize)
                    .padding(.leading , 8)
                NSControlViewDefaultText(text: "\(nOfPitanga)un", textSize: smalTxtSize)
                    .padding(.leading , 32)
            }
            .position(CGPoint(x: geometry.size.width / 1.56 , y: geometry.size.height / 2.05))
        }
    }
}
