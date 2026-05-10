//
//  ContentView.swift
//  PocGameKitENetwork
//
//  Created by Vinicius Marques on 11/02/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var matchManager = MatchManagerViewModel.shared
    var body: some View {
        ZStack {
            if matchManager.isGameOver{
                GameOver(matchManager: matchManager)
            } else if matchManager.inGame{
                GameView(matchManager: matchManager)
            }else{
                MenuView(matchManager: matchManager)
            }
        }
        .ignoresSafeArea()
        .onAppear(){
            matchManager.authenticateUser()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
