//
//  EmBreveComponent.swift
//  C8
//
//  Created by Thais Cangucu on 13/11/25.
//

import SwiftUI
struct EmBreveComponent: View {
    var body: some View {
        ZStack{
            Circle()
                .fill(.laranja)
                .overlay(
                    Circle()
                        .stroke(.accent, lineWidth: 8)
                )
                .frame(width: 100)
            Text("Em breve")
                .foregroundStyle(.white)
                .font(.custom("Nunito-Bold", size: 15))
        }
    }
}
