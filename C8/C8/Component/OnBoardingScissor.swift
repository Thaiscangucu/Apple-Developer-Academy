//
//  OnBoardingScissor.swift
//  C8
//
//  Created by Jonas Fernando Nascimento Melo on 03/11/25.
//

import SwiftUI

struct OnBoardingScissor: View {
    
    @Binding var animationSprite: String
    @State var animationY: CGFloat = 0
    @Binding var nextView: Bool
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

            }
            
            Spacer()
            
          
                Image("OnboardingPics_ScissorGrey")
                    .resizable()
                    .frame(width: 92, height: 87)
                
                Image(animationSprite)
                    .resizable()
                    .frame(width: 92, height: 88)
                    .offset(x: 0, y: animationY)
                    .padding(.horizontal,0)
            
            
            Spacer()
            
            Button {
                nextView = true
            } label: {
                Text("Próximo")
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
        repeat {
            _ = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: animationTrigger,) { (Timer) in
                
                if animationY == -1{
                    isFixed = true
                    animationSprite = "OnboardingPics_ScissorTouch"
                    if count == 40 {
                        count = 0
                        animationSprite = "OnboardingPics_scissorDrag"
                        isFixed = false
                    }
                }
                
                if animationY == -93{
                    isFixed = true
                    if count == 20{
                        animationY = 0
                        animationSprite = "OnboardingPics_ScissorTouch"

                        count = 0
                        isFixed = false
                    }
             
                }
                if isFixed == true{
                    count += 1
                }
                if isFixed == false {
                    animationY -= 1
                }
            }
            
        }while animationY <= -94
    }
}

#Preview {
    @Previewable @State var animationSprite = "OnboardingPics_ScissorTouch"
    @Previewable @State var nextView: Bool = false
    OnBoardingScissor(animationSprite: $animationSprite, nextView: $nextView)
}
