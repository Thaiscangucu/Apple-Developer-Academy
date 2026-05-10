//
//  MenuView.swift
//  POCNetWorkGameCenter
//
//  Created by Vinicius Marques on 11/02/26.
//

import SwiftUI
import GameKit

struct GameOver: View {
    @ObservedObject var matchManager = MatchManagerViewModel.shared
    var body: some View {
        VStack {
            Text("Acabou!")
        }
        Text(matchManager.authenticationState.rawValue)
            .font(.headline)
        .padding()
    }
}

#Preview {
    MenuView()
}
