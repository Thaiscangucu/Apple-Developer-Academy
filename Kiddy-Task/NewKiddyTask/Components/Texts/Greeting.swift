//
//  SwiftUIView.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 01/02/26.
//

import SwiftUI

struct Greeting: View {
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("Olá colega!!")
                    .font(.custom("Qilka", size: 41))
                    .foregroundStyle(.textGray)
                    .padding(.top, 50)
            }
            Text("vamos nos preparar?")
                .fontDesign(.rounded)
                .font(.custom("", size: 21))
                .fontWeight(.medium)
                .foregroundColor(Color(red: 0.32, green: 0.32, blue: 0.32))
        }
    }
}

#Preview {
    Greeting()
}
