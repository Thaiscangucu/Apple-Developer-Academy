//
//  JoyStickView.swift
//  ProximaEstacao
//
//  Created by Lucca Pivoto on 02/03/26.
//
import SwiftUI
import Foundation
import UIKit
import GameController
import GameKit
import _SpriteKit_SwiftUI
internal import Combine

#if os(iOS)

struct ControlMainView: View {
    
    @ObservedObject var matchManager = MatchManagerViewModel.shared
    @State var joyStick : SpriteView?
//    @State var player   : Arara
    @State var controlType : Int = 0
    
    var body: some View {
        Group{
//            if controlType == 1 {
//                ArarasControlLandscapeView(player: $player)
//                    .onAppear(){
//                        joyStick = SpriteView(scene: ControleScene())
//                    }
//            }
            if controlType == 2{
                DogsControlLandscapeView()
                    .onAppear(){
                        joyStick = SpriteView(scene: ControleScene())
                    }
            }
            else {
                DefaultBGControler()
                    .onAppear(){
                        joyStick = SpriteView(scene: ControleScene())
                    }
            }
            
        }
        .onAppear {
            // Forcing the rotation to portrait
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
        .onDisappear {
            // Unlocking the rotation when leaving the view
            DispatchQueue.main.async {
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
}

#endif
