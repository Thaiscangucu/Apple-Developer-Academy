//
//  ObjetivosView.swift
//  C8
//
//  Created by Isabela Hissa Pinto on 29/10/25.
//

import SwiftUI
import CoreData

struct ObjetivosView: View {
    var objSize: CGFloat = 60
    var objetos: [String]
    @Binding var isChosen: [Bool]
    @Binding var actualProgress: [Double]
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.beige
                    .ignoresSafeArea()
                VStack(spacing: 30){
                    PersonalizedDivider()
                        .padding(.top, 50)
                    ForEach(objetos.enumerated(), id: \.offset) { index, objeto in
                        //Ajeitar pro ultimo obj não aparecer
                        if index != 3 {
                            ObjetivosComponent(objImage: objeto, actualProgress: $actualProgress[index], isChosen: $isChosen[index])
                            PersonalizedDivider()
                        }
                    }
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Objetivos")
                            .font(.custom("Nunito-Bold", size: 34))
                            .offset(x: -101, y: 56)
                    }
                }
            }
        }
    }
}

#Preview {
    ObjetivosView(objetos: ["Scissor", "Shaver", "BlowDryer", "Shower"], isChosen: .constant([true, true, false, false]), actualProgress: .constant([3, 2, 0.0, 0.0]))
}
