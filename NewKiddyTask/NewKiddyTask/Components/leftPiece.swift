//
//  rightPiece.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 03/02/26.
//

import SwiftUI

struct leftPiece: View {
//    var recompensa: Recompensa
    var text: String
    var freq: Int
//    @State var darkerColor: Color = .white
    var body: some View {
        ZStack{
            Image("leftPiece")
                .resizable()
                .scaledToFit()
                .frame(width: 183, height: 166)
            VStack{
//                Text(recompensa.title)
                Text(text)
                    .font(.custom("Qilka", size: 19))
                    .multilineTextAlignment(.center)
//                    .foregroundColor(darkerColor)
                    .foregroundColor(Color(red: 0.75, green: 0.62, blue: 0.01))
                    .frame(width: 120, height: 80, alignment: .top)
                    .padding(.top, 8)
                Spacer()
//                Text("0/\(recompensa.frequencia)")
                Text("0/\(freq)")
                  .font(.custom("Qilka", size: 13))
//                  .foregroundColor(darkerColor)
                  .foregroundColor(Color(red: 0.75, green: 0.62, blue: 0.01))
                  .padding(.bottom, 2)
                
                //Progress Bar
            }
            .frame(height: 110)
        }
//        .onAppear{
//            switch recompensa.color{
//            case .greenRecompensa:
//                darkerColor = Color(red: 0.45, green: 0.72, blue: 0.08)
//            case .yellowRecompensa:
//                darkerColor = Color(red: 1, green: 0.55, blue: 0.01)
//            case .redRecompensa:
//                darkerColor = Color(red: 1, green: 0, blue: 0.2)
//            default:
//                darkerColor = .black
//            }
//        }
    }
}

//#Preview {
//    leftPiece()
//}
