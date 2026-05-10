//
//  AssistiveAccessContentView.swift
//  C8
//
//  Created by Binho Gadelha on 04/11/25.
//

import SwiftUI

struct AssistiveAccessContentView: View {
    @Environment(\.accessibilityAssistiveAccessEnabled) var accessibilityAssistiveAccessEnabled
    var body: some View {
        
        NavigationStack{
            ZStack{
//                Image("canos")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 400)
                VStack(spacing: 20){
                    NavigationLink{
                        CabeleleiroACView(objetos: ["Scissor", "Shaver","BlowDryer", "Shower"])
                    }label:{
                        AmbientComponentAC(icon: "scissors", title: "cabeleireiro")
                    }
                    EmBreveComponent()
                    EmBreveComponent()
                    EmBreveComponent()

                }
                .frame(width: 460, height: 900)
                //Navigation's title
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Ambientes")
                            .font(.custom("Nunito-Bold", size: 34))
                            .offset(x: -101, y: 30)
                    }
                }
            }
            .background(.ambientsBackground)
        }
    }
}

#Preview {
    AssistiveAccessContentView()
}
