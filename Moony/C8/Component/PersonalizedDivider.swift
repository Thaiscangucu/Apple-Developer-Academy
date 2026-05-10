//
//  PersonalizedDivider.swift
//  C8
//
//  Created by Isabela Hissa Pinto on 30/10/25.
//

import SwiftUI

struct PersonalizedDivider: View {

    var body: some View {
        Rectangle()
            .frame(width: UIScreen.main.bounds.width * 0.88, height: 1)
            .foregroundColor(.darkBeige)
    }
}

#Preview {
    PersonalizedDivider()
}
