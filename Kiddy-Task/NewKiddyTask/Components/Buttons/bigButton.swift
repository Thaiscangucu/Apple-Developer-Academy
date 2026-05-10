//
//  estouProntoButton.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 01/02/26.
//

import SwiftUI

struct bigButton: View {
    var text: String
    var thumbsUp: Bool
    var body: some View {
        ZStack{
            Image("RecButton")
                .resizable()
                .scaledToFit()
                .frame(width: 280)
            HStack(spacing: 0){
                Text(text)
                    .font(.custom("Qilka", size: 28))
                    .foregroundColor(Color(red: 0.63, green: 0.8, blue: 0.83))
                Text("!")
                    .font(.system(size: 35))
                    .bold()
                    .fontDesign(.rounded)
                    .foregroundColor(Color(red: 0.63, green: 0.8, blue: 0.83))
                    .padding(.bottom, 4)
                    
                if thumbsUp{
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0.63, green: 0.8, blue: 0.83))
                }
            }
        }
    }
}
