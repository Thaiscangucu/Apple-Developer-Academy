//
//  ContentView.swift
//  MacOsFront
//
//  Created by Jonas Fernando Nascimento Melo on 20/08/25.
//

import SwiftUI

enum SideBarItem: String, Identifiable, CaseIterable{
    var id: String { rawValue }
    
    case queue
    case membros
    case perfil
}

struct ContentView: View {
    
    
    var body: some View {
        
        
        LoginView(statusCode: HTTPResponse.ok )
            .modelContainer(for: User.self)
        
        //            NavigationView {
        //                List {
        //                    NavigationLink {
        ////                        MacQueueView()
        //                        MacQueueView()
        //                    } label: {
        //                        Image(systemName: "questionmark.bubble.fill")
        //                            .font(.largeTitle)
        //                    }
        //
        //                    NavigationLink {
        //                        MacMamberTeam()
        //                    } label: {
        //                        Image(systemName: "person.2.fill")
        //                            .font(.largeTitle)
        //                    }
        //
        //                }
        //            }
    }
}

#Preview {
    ContentView()
}
