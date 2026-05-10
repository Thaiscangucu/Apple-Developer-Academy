//
//  CardView.swift
//  Front
//
//  Created by João Pedro Pioltini de Oliveira on 26/08/25.
//

import SwiftUI

struct CardView: View {
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 170, height: 170)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.25), radius: 4.3, x: 5, y: 4)
            .padding(.top, 2)
    }
}
