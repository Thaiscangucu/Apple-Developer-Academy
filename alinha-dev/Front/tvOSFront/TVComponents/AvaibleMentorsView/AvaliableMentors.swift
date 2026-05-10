//
//  AvaliableMentors.swift
//  tvOSFront
//
//  Created by João Pedro Pioltini de Oliveira on 27/08/25.
//

import SwiftUI
///Swift UI Component that shows all the avaible and unvaiable mentors with their icons and names.
///
struct AvaliableMentors: View {

    @Binding var appointments: [GetAppointments]
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.clear)
                .background(.lightBlue)
            VStack{
                Text("Mentores")
                    .foregroundStyle(Color.darkBlueText)
                    .font(.system(size: 38, weight: .bold))
                    .padding(.vertical,15)
                MentorComponent(appointments: $appointments)
                Spacer()
            }
        }
        .frame(width: 600, height: 550)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}
