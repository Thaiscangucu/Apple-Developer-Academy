//
//  PlayerRoleView.swift
//  ProximaEstacao
//
//  Created by Thomas Pinheiro Grandin on 03/03/26.


import SwiftUI
import GameKit
#if os(tvOS)
struct PlayerRoleView: View {
    @ObservedObject var matchManager = MatchManagerViewModel.shared
    @State var numPlayer: Int
    var body: some View {
        VStack {
            if numPlayer == 2 {
                Button(action: {
                    SceneManager.shared.currentScene.loadPlayer( araras: 1, cachorros: 1)
                    matchManager.menu = false
                }, label: {
                    Text("Clique para começar o jogo com: 1 Arara, 1 Cachorro")
                })
            }
           else if numPlayer == 3 {
                Button(action: {
                    SceneManager.shared.currentScene.loadPlayer( araras: 2, cachorros: 1)
                    matchManager.menu = false
                }, label: {
                    Text("Clique para começar o jogo com: 2 Araras, 1 Cachorro")
                })
                Button(action: {
                    SceneManager.shared.currentScene.loadPlayer( araras: 1, cachorros: 2)
                    matchManager.menu = false
                }, label: {
                    Text("Clique para começar o jogo com: 1 Arara, 2 Cachorros")
                })
            }
            else if numPlayer == 4 {
                Button(action: {
                    SceneManager.shared.currentScene.loadPlayer(araras: 2, cachorros: 2)
                    matchManager.menu = false
                }, label: {
                    Text("Clique para começar o jogo com: 2 Araras, 2 Cachorros")
                })
                Button(action: {
                    SceneManager.shared.currentScene.loadPlayer(araras: 3, cachorros: 1)
                    matchManager.menu = false
                }, label: {
                    Text("Clique para começar o jogo com: 3 Araras, 1 Cachorro")
                })
                Button(action: {
                    SceneManager.shared.currentScene.loadPlayer(araras: 1, cachorros: 3)
                    matchManager.menu = false
                }, label: {
                    Text("Clique para começar o jogo com: 1 Arara, 3 Cachorros")
                })
            }
            else {
                Button(action: {
                    SceneManager.shared.currentScene.loadPlayer(araras: 0, cachorros: 1)
                    matchManager.menu = false
                }, label: {
                    Text("Clique para começar o jogo com: 0 Araras, 1 Cachorro")
                })
            }
        }
    }
}

#Preview {
    //    PlayerRoleView(matchManager: MatchManagerViewModel())
}
#endif
