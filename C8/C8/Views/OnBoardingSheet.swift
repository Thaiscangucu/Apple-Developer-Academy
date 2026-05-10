//
//  Onboarding.swift
//  Challenge8
//
//  Created by Jonas Fernando Nascimento Melo on 09/10/25.
//

import SwiftUI

struct OnboardingSheet: View {
    @Binding var isWelcomeSheetShowing: Bool
    @State var nextView: Bool = false
    @State var animationY: CGFloat = 0
    @State var animationSprite: String = "OnboardingPics_ScissorTouch"
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 300 ,height: 390)
                .foregroundStyle(.white)
                .padding(.bottom, 30)

            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.accent, lineWidth: 4)
                .frame(width: 300 ,height: 390)
                .shadow(radius: 5)
                .padding(.bottom, 30)
                .overlay {
                    if !nextView{
                        OnBoardingScissor(animationSprite: $animationSprite, nextView: $nextView)
                            .padding(.bottom,30)
                    }
                    else{
                        OnBoardingTrash(isWelcomeSheetShowing: $isWelcomeSheetShowing)
                            .padding(.bottom,30)
                    }
                    
                }
        }
    }
}


#Preview {
    @Previewable @State var isWelcomeSheetShowing: Bool = true
    
    OnboardingSheet(isWelcomeSheetShowing: $isWelcomeSheetShowing)
}
