//
//  FrontApp.swift
//  Front
//
//  Created by Jonas Fernando Nascimento Melo on 20/08/25.
//
import SwiftData
import SwiftUI

@main
struct FrontApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var push = PushManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
            //            SignUpView()
                .onAppear {
                    push.requestAuthorizationAndRegister()
                }
//            SignUpView()
//            ContentView()
        }
    }
}


//TODO: - IMPLEMENTAÇÃO:
// - Ativar a capabilitie de Push notification
// - Alterar o codigo no back com o token do Jonas ( mandou pro TF)
// - Como implementar no POST de appointment:
//          @StateObject private var push = PushManager.shared
//          guard let token = push.deviceTokenHex else { return }
