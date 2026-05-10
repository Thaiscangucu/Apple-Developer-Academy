//
//  DefaultBGControler.swift
//  ProximaEstacao
//
//  Created by Lucca Pivoto on 05/03/26.
//

import SwiftUI
import Foundation

struct DefaultBGControler: View{
    var body: some View{
        ZStack(){
            Color("NSBackGround")
            GeometryReader{ geometry in
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: geometry.size.width / 1.15 , height: geometry.size.height / 1.2)
                    .position(CGPoint(x: geometry.size.width / 2.1 , y: geometry.size.height / 2))
                    .foregroundStyle(Color("NSLightBackgroundColor"))
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    DefaultBGControler()
}
