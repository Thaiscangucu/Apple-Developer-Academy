//
//  AmbientComponentAC.swift
//  C8
//
//  Created by Binho Gadelha on 05/11/25.
//

import SwiftUI

struct AmbientComponentAC: View {
    var icon: String
    var title: String
    
    var body: some View {
        ZStack{
            Group{
//                Image("elipse")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 120)
                if title == ""{
                    Text("?")
                        .foregroundStyle(.white)
                        .font(.custom("Nunito-Bold", size: 20))
                        .padding(.top)
                }
//                Image(title)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 90)
            }
            .offset(y:55)
            Circle()
                .fill(.laranja)
                .frame(width: 100)
                .overlay(
                    Circle()
                        .stroke(.accent, lineWidth: 8)
                )
            if icon == "airplane"{
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 60)
                    .rotationEffect(.degrees(-48.55))
                    .offset(x: 5)
            }
            else{
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 60)
                    .rotationEffect(.degrees(-48.55))
                    .offset(x: 4)
            }
        }
    }
    
}


#Preview {
    AmbientComponentAC(icon: "airplane", title: "")
}
