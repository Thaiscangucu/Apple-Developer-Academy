//
//  PositionView.swift
//  iOSFront
//
//  Created by Francisco Losada on 27/08/25.
//

import SwiftUI

/// Component for 
/// - Parameter description: It's the variable that gets the user's description.
/// - Parameter role: It's the array that shows to the user the roles that can be selected by the picker.
/// - Parameter problem: It's the array that shows to the user the category problems that can be selected by the picker.
/// - Parameter selectRole: It's the variable that gets the chosen role and shows on the picker, alowing the view for the user.
/// - Parameter selectProblem: It's the variable that gets the chosen category problem and shows on the picker, alowing the view for the user.
/// - Parameter name: It's the variable that shows the user's name on the card.
struct PositionStudent: View {
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Você está em _º lugar")
                    .font(.title2)
                    .fontWeight(.medium)
                Button {
                    //code
                } label: {
                    Text("cancelar")
                        .frame(width: 245, height: 38)
                        .font(.title3)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
            .frame(width: 360, height: 128)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}

#Preview {
    PositionStudent()
}
