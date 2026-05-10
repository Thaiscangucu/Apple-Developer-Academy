//
//  DefaultButton.swift
//  Front
//
//  Created by Isabela Hissa Pinto on 26/08/25.
//

import SwiftUI

struct DefaultButton: View {
    var buttonName: String
    
    var body: some View {
        Text(buttonName)
            .bold()
            .buttonStyle(.plain)
            .cornerRadius(10)
            .padding(5)
            .foregroundColor(.black)
            .background(
                Rectangle()
                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85))
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                    .cornerRadius(8)
                    .frame(width: 200,height: 40))
    }
}

#Preview {
    DefaultButton(buttonName: "Confirmar")
}
