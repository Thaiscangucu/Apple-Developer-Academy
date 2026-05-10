//
//  SwiftUIView.swift
//  C8
//
//  Created by Isabela Hissa Pinto on 27/10/25.
//

import SwiftUI
import SpriteKit
import CoreData

struct TestView: View {
    @Environment(\.dismiss) var dismiss

    var barbearia: GenericScene = GenericScene(backgroundName: "bkg", objetos: ["Scissor", "Shaver", "BlowDryer"], ambient: "Barber", )
    
    var scene: SKScene {
        let scene = barbearia
        scene.size = CGSize(width: UIScreen.main.bounds.width * 1.3, height: UIScreen.main.bounds.height * 1)
        scene.scaleMode = .fill
        return scene
    }
    
    var body: some View {
        NavigationStack{
            SpriteView(scene: scene)
                .frame(width: UIScreen.main.bounds.width * 1.4, height: UIScreen.main.bounds.height * 1.15)
                .ignoresSafeArea()
        }
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
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TestView()
}
