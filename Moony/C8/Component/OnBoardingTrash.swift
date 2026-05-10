//
//  OnBoardingTrash.swift
//  C8
//
//  Created by Jonas Fernando Nascimento Melo on 03/11/25.
//

import SwiftUI

struct OnBoardingTrash: View {
    
    @State var animationSprite: String = "OnboardingPics_ScissorTouch"
    @State var animationX: CGFloat = 50
    @State var animationY: CGFloat = 1
    @Binding var isWelcomeSheetShowing: Bool
    @State var animationTrigger: Bool = true
    
    
    var body: some View {
        
        VStack(alignment: .center){
            
            VStack(alignment: .leading){
                Text("Segure e Arraste")
                    .foregroundStyle(Color.onBoardingText)
                    .font(.system(size: 17))
                    .foregroundStyle(.black)
                    .padding(.top,8)
                
                Text("Os objetos para dentro do cenário e descubra seu som!")
                    .font(.system(size: 16))
                    .padding(.top,4)
                    .foregroundStyle(.black)
                
                
                Spacer()
                
                Image(animationSprite)
                    .resizable()
                    .frame(width: 92, height: 88)
                    .offset(x: animationX, y: animationY)
                    .padding(.horizontal,0)
                
                Image("OnboardingPics-trash")
                    .resizable()
                    .frame(width: 63, height: 86)
                    .offset(x:160)
                
                
                
                
                Spacer()
                
                Button {
                    isWelcomeSheetShowing = false
                } label: {
                    Text("Entendi!")
                        .font(.title3)
                        .frame(maxWidth: 264, maxHeight: 40)
                        .foregroundStyle(.white)
                        .bold()
                    
                }
                .tint(Color.accentOrange)
                .buttonStyle(.borderedProminent)
                .frame(alignment: .center)
            }
            
            .padding(14)
        }
        .onAppear{
            Task{
                do{
                    try await Animationtimer()
                }
                catch{
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    func Animationtimer() async throws{
        var isFixed: Bool = false
        var count = 0
 
            _ = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: animationTrigger) { (Timer) in
               
                if animationX == 50{
                    isFixed = true
                    animationSprite = "OnboardingPics_ScissorTouch"
                    if count == 40 {
                        count = 0
                        animationSprite = "OnboardingPics_scissorDrag"
                        isFixed = false
                    }
                }
                if animationX == 150{
                    isFixed = true
                    if count == 20{
                        animationY = 1
                        animationX = 49
                        
                        count = 0
                        isFixed = false
                    }
                    
                }
                if isFixed == true{
                    count += 1
                }
                
                if isFixed == false{
                    if animationX > 62 && animationY < 65 {
                        
                        animationY = animationY*1.05
                        
                    }
                    animationX += 1
                }
            }
            
            
       
    }
}

#Preview {
    @Previewable @State var animationSprite = "OnboardingPics_ScissorTouch"
    @Previewable @State var isWelcomeSheetShowing: Bool = false
    OnBoardingTrash(isWelcomeSheetShowing: $isWelcomeSheetShowing)
}
