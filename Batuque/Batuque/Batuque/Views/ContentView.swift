//
//  ContentView.swift
//  Batuque
//
//  Created by Pedro Augusto on 08/12/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @State var viewModel = NoteViewModel()
    
    let regexNotes: Regex = /Note([A-Za-z0-9]+)/
    let regexButtons: Regex = /Button([0-9]+)/
    
    @State var folder: String = "Goofy"
    @State var id: String = ""
    
    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "TouchPad", in: realityKitContentBundle) {
                content.add(scene)
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { tap in
            if let match = tap.entity.name.firstMatch(of: regexButtons) {
                if match.1 == "1" {
                    folder = "Goofy"
                    id = ""
                }
                else if match.1 == "2" {
                    folder = "Drums"
                    id = "D"
                }
                else if match.1 == "3" {
                    folder = "Piano"
                    id = "P"
                }
            }
            else {
                if let matchNote = tap.entity.name.firstMatch(of: regexNotes) {
                    guard let path2: String = Bundle.main.path(forResource: "\(matchNote.1)\(id)", ofType: "mp3") else { return }
                    viewModel.playNote(path2)
                    print(path2)
                }
            }
        })
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
