//
//  CalendarBackground.swift
//  HabitosImprove
//
//  Created by Thais Canguçu on 27/07/25.
//

import SwiftUI

struct CalendarBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .ignoresSafeArea()
            .frame(width: 400, height: 300)
            .foregroundStyle(.beige)
    }
}

#Preview {
    CalendarBackground()
}
