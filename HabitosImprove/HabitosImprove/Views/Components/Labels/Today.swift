//
//  AllHabitsComponent.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 14/07/25.
//

import SwiftUI

struct Today: View {
    
    var body: some View {
        ZStack {
            LabelRect(redWidth: 150)
                .shadow(color: .sombra, radius: 2, x: 0, y: 4)
            
            Text("Today")
                .font(.largeTitle)
                .bold()
                .fontDesign(.rounded)
        }
        .padding(.bottom, 100)
    }
}

#Preview {
    Today()
}
