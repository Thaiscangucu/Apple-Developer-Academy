//
//  AmbientComponent.swift
//  C8
//
//  Created by Jonas Fernando Nascimento Melo on 21/10/25.
//
import SwiftUI


struct AmbientComponent: View {
    var icon: String
    var title: String
    
    var body: some View {
        ZStack{
            Group{
                Image("elipse")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                if title == ""{
                    Text("?")
                        .foregroundStyle(.white)
                        .font(.custom("Nunito-Bold", size: 20))
                        .padding(.top)
                }
                Image(title)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90)
            }
            .offset(y:55)
            Circle()
                .fill(.laranja)
                .overlay(
                    Circle()
                        .stroke(.accent, lineWidth: 8)
                )
                .frame(width: 100)
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

#Preview{
    AmbientComponent(icon: "airplane", title: "")
}
