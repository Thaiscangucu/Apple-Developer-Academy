//
//  Rectangle.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 14/07/25.

import SwiftUI
struct LabelRect: View {
    var redWidth: CGFloat
    var body: some View {
            RoundedRectangle(cornerRadius: 25)
            .frame(width: redWidth, height: 60)
                .foregroundStyle(.darkerGreen)
                .opacity(0.7)
    }
}
#Preview {
    LabelRect(redWidth: 200)
}
