//
//  MenuView.swift
//  POCNetWorkGameCenter
//
//  Created by Vinicius Marques on 11/02/26.
//

import SwiftUI
import GameKit

struct MenuView: View {
    @ObservedObject var matchManager =  MatchManagerViewModel.shared
    var body: some View {
        ZStack {        
            VStack {
                Button{
                    matchManager.startMatchMaking()
                }label: {
                    Image("MenuImage")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
                .disabled(matchManager.authenticationState != .authenticated || matchManager.inGame)
                .buttonStyle(.bordered)
                .foregroundStyle(matchManager.authenticationState != .authenticated || matchManager.inGame ? .gray : .blue)
            }
           
        }
    }
}

#Preview {
    MenuView(matchManager: MatchManagerViewModel.shared)
}
