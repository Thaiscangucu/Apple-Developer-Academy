//
//  CabeleleiroACView.swift
//  C8
//
//  Created by Binho Gadelha on 04/11/25.
//

import SwiftUI
import SpriteKit

struct CabeleleiroACView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isWelcomeSheetShowing") var isWelcomeSheetShowing: Bool = true
    @State var viewModel: CoreDataViewModel = CoreDataViewModel()
    @State var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State var levels: [Bool] = []
    @State var actualProgress: [Double] = []
    var objetos: [String]
    
    var scene: SKScene {
        //        let scene = BarberSpriteKitScene()
        let sceneAC = GenericACScene(backgroundName: "bkg", objetos: ["Scissor", "Shaver","BlowDryer", "Shower"], ambient: "Barber")
        sceneAC.size = CGSize(width: UIScreen.main.bounds.width * 1.3, height: UIScreen.main.bounds.height)
        sceneAC.scaleMode = .fill
        
        return sceneAC
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                SpriteView(scene: scene)
                    .frame(width: UIScreen.main.bounds.width * 1.4, height: UIScreen.main.bounds.height * 1.15)
                //Fetch dos objetos no Core Data
                if isWelcomeSheetShowing{
                    OnboardingSheet(isWelcomeSheetShowing: $isWelcomeSheetShowing)
                    
                }
                VStack(alignment: .trailing) {
                    HStack (alignment: .top) {
                //TODO: Botao do OnBoarding
                        
//                        Button {
//                       isWelcomeSheetShowing = true
//                        } label: {
//                            Image("giftPurple")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 30)
//
//                        }.padding(.top, -300)
                    }
                }
                
            }
        }
        .onAppear{
            viewModel.getObjeto()
        }
        .task {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                
                viewModel.getObjeto()
                viewModel.setActualProgress(objName: objetos)
                actualProgress = viewModel.actualProgress
                levels = viewModel.levels
                
            }
        }
        
        .ignoresSafeArea()
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                }label: {
                    Image(systemName: "chevron.left")
                    Text("Voltar")
                }
                .foregroundStyle(.accent)
            }
        }
        
        .toolbar{
            ToolbarItem() {
                Button {
                    isWelcomeSheetShowing = true
                } label: {
                    Text("Como usar")
                    Image(systemName: "questionmark.square.fill")
                }
                .foregroundStyle(.accent)
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Cabeleireiro")
        .assistiveAccessNavigationIcon(systemImage: "scissors")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CabeleleiroACView(objetos: ["Scissor", "Shaver","BlowDryer", "Shower"])
}
