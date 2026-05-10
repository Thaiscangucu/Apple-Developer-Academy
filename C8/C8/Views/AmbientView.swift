//
//  CabeleleiroView.swift
//  C8
//
//  Created by Jonas Fernando Nascimento Melo on 14/10/25.
//

import SwiftUI
import SpriteKit

struct AmbientView: View {
    
    
    
    var background: String
    var objetos: [String]
    var ambiente: String
    @Environment(\.dismiss) var dismiss
    @AppStorage("isWelcomeSheetShowing") var isWelcomeSheetShowing: Bool = true
    @State var viewModel: CoreDataViewModel = CoreDataViewModel()
    @State var actualProgress: [Double] = []
    @State var levels: [Bool] = []
    @State var timer = Timer.publish(every: 1, on: .main, in: .common)
    
    var scene: SKScene {
        let scene = GenericScene(backgroundName: background, objetos: objetos, ambient: ambiente)
        scene.size = CGSize(width: UIScreen.main.bounds.width * 1.3, height: UIScreen.main.bounds.height )
        scene.scaleMode = .fill
        return scene
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                Rectangle()
                    .frame(width: 1000, height: 1000)
                    .foregroundStyle(Color.barber)
                SpriteView(scene: scene)
                    .frame(width: UIScreen.main.bounds.width * 1.4, height: UIScreen.main.bounds.height * 1.15)

            }
            .background{
                Color.accentOrange
            }
            .ignoresSafeArea()
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
        }
        .onAppear{
            viewModel.getObjeto()
            if ambiente != "Barber"{
                isWelcomeSheetShowing = false
            }
        }
        .sheet(isPresented: $isWelcomeSheetShowing){
            historiaSocial(isWelcomeSheetShowing: $isWelcomeSheetShowing)
                .presentationDetents([.large])
        }
        .toolbar{
            ToolbarItem() {
                if ambiente ==  "Barber"{
                    Button {
                        isWelcomeSheetShowing = true
                    } label: {
                        Image(systemName: "questionmark.square.fill")
                    }
                    .foregroundStyle(.accent)
                }
            }
        }
        .toolbar{
            ToolbarItem() {
                
                NavigationLink{
                    ObjetivosView(objSize: 60, objetos: objetos, isChosen: $levels, actualProgress: $actualProgress)
                } label: {
                    Image("giftPurple")
                        .resizable()
                        .frame(width: 22, height: 22)
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Cabeleireiro")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AmbientView(background: "Airport", objetos: ["Scissor", "Shaver","BlowDryer","Shower"], ambiente: "Barber")
}
