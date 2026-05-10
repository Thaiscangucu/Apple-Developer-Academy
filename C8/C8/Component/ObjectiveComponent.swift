//
//  ObjectiveComponent.swift
//  C8
//
//  Created by Isabela Hissa Pinto on 29/10/25.
//

import SwiftUI

struct ObjetivosComponent: View {
    var objSize: CGFloat = 50
    var objImage: String
    var maxProgress: Double = 3
    @Binding var actualProgress: Double
    @Binding var isChosen: Bool
    
    var body: some View {
        VStack(spacing: 0){
            HStack(spacing: 17) {
                if isChosen == true {
                    Image(objImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: objSize)
                    ProgressBar(actualProgress: $actualProgress, maxProgress: 3, color: .accent)
                } else {
                    Text("?")
                        .font(.largeTitle)
                        .padding(.trailing, 15)
                    ProgressBar(actualProgress: .constant(0), maxProgress: 3, color: .accent)
                }
                Image("Reward")
                    .resizable()
                    .scaledToFit()
                    .frame(width: objSize)
                    .padding(.bottom, 10)
            }
            Text(isChosen ? "\(Int(min(actualProgress, maxProgress)))/3" : "0/3")
        }
    }
}


#Preview {
    ObjetivosComponent(objImage: "Scissor", actualProgress: .constant(2), isChosen: .constant(true))
}
