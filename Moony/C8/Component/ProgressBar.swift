//
//  ProgressBarUI.swift
//  C8
//
//  Created by Jonas Fernando Nascimento Melo on 29/10/25.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var actualProgress: Double
    var maxProgress: Double
    var progress: Double {
        min(actualProgress/maxProgress,1)
    }
    var color: Color
    var body: some View {
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 100)
                .frame(width: 230, height: 25)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(color, lineWidth: 4)
                )
            RoundedRectangle(cornerRadius: 100)
                .frame(width: 230, height: 25)
                .foregroundColor(color)
                .opacity(0.1)
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(color, lineWidth: 4)
                )
                RoundedRectangle(cornerRadius: 100)
                    .frame(width: 230 * progress, height: 30)
                    .foregroundColor(color)
                    .animation(.linear, value: progress)
        }
    }
}

#Preview {
    ProgressBar(actualProgress: .constant(4), maxProgress: 5, color: .accent)
}
