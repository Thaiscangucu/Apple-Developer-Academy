//
//  rightPiece.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 03/02/26.
//

import SwiftUI

struct rightPiece: View {
//    var recompensa: Recompensa
    var text: String
    var freq: Int
    @State var darkerColor: Color = .white
    
    var body: some View {
        ZStack{
            Image("Union")
                .resizable()
                .scaledToFit()
                .frame(width: 183, height: 166)
//                .foregroundStyle(Color(recompensa.color))
                .foregroundStyle(Color.redRecompensa)
            VStack{
//                Text(recompensa.title)
                Text(text)
                    .font(.custom("Qilka", size: 19))
//                    .foregroundColor(darkerColor)
                    .foregroundColor(Color(red: 0.95, green: 0.26, blue: 0.4))
                    .frame(width: 90, height: 100, alignment: .top)
                    .padding(.top, 4)
                    .multilineTextAlignment(.center)
                Spacer()
//                Text("0/\(recompensa.frequencia)")
                Text("0/\(freq)")
                    .font(.custom("Qilka", size: 13))
//                    .foregroundColor(darkerColor)
                    .foregroundColor(Color(red: 0.95, green: 0.26, blue: 0.4))

                //Progress Bar
            }
            .padding(.trailing, 17)
            .frame(height: 125)
        }
//        .onAppear{
//            switch recompensa.color{
//            case "greenRecompensa":
//                darkerColor = Color(red: 0.45, green: 0.72, blue: 0.08)
//            case "yellowRecompensa":
//                darkerColor = Color(red: 1, green: 0.55, blue: 0.01)
//            case "redRecompensa":
//                darkerColor = Color(red: 1, green: 0, blue: 0.2)
//            default:
//                darkerColor = .black
//            }
//        }
    }
}

//#Preview {
//    rightPiece()
//}
