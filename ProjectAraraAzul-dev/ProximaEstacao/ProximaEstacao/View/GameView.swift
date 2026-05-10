//
//  GameView.swift
//  POCNetWorkGameCenter
//
//  Created by Vinicius Marques on 11/02/26.
//

import SwiftUI
import GameKit
import SpriteKit

struct GameView: View {
    @ObservedObject var matchManager = MatchManagerViewModel.shared
    @State var passei = false
    @State var scene = SKScene(size: CGSize(width: 1920, height: 1080))
    
    var body: some View {
#if os(tvOS)
        ZStack {
            if matchManager.menu {
                PlayerRoleView(matchManager: matchManager, numPlayer: matchManager.match!.players.count)
            }else{
                SpriteView(scene: scene)
//                    .onAppear(){
//                        var ids: [String] = []
//                        for player in matchManager.match!.players {
//                            print(player.gamePlayerID)
//                            ids.append(player.gamePlayerID)
//                        }
//                        scene.receiveIDs(ids: ids, araras: 1, cachorros: 1)
//                    }
            }
        }.onAppear(){
         #if os(tvOS)
           if !passei {
               scene = SceneManager.shared.currentScene
               passei = true
           }
           #endif
        }
        
#endif
        
#if os(iOS)
        ZStack(){
            SpriteView(scene: ControleScene())
                .ignoresSafeArea()
            ControlMainView()
        }
#endif
    }
}

#Preview {
    GameView()
}
