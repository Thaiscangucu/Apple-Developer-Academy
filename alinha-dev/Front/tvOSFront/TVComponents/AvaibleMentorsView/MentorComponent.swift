//
//  MentorComponent.swift
//  tvOSFront
//
//  Created by Thais Cangucu on 04/09/25.
//

import Foundation
import SwiftUI
///SwiftUI Component for each mentor with their names and icons
///
struct MentorComponent: View{
    @Binding var appointments: [GetAppointments]
    var circleSize: CGFloat = 90
    let columns: [GridItem] = [
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top)
    ]
    
    var body: some View{
        LazyVGrid(columns: columns){
            ForEach(appointments, id: \.id){ appointment in
                VStack(spacing: 16){
                    //                    if mentor.disponivel == true{
                    VStack{
                        ZStack{
                            // Mentor's icon
                            Circle()
                                .frame(width: 80, height: 80)
//                                .foregroundStyle(.iconCircle)
                                .foregroundStyle(.studentCardBackground)
                            Circle()
                                .stroke(Color.black, lineWidth: 3)
                                .frame(width: circleSize, height: circleSize)
                        }
                        // Mentor's name
                        Text(appointment.mentor)
                            .font(.system(size: 23, weight: .regular))
                            .foregroundStyle(.black)
                            .frame(width: 110, alignment: .center)
                            .lineLimit(1)
                    }
                    //                    }
                    //                    else{
                    //                        VStack{
                    //                            Circle()
                    //                                .frame(width: circleSize, height: circleSize)
                    //                                .foregroundStyle(.iconCircle)
                    //
                    //                            Text(mentor.name)
                    //                                .font(.system(size: 23, weight: .regular))
                    //                                .foregroundStyle(.black)
                    //                        }
                    //                    }
                }
                //                .opacity(mentor.disponivel ? 1 : 0.67)
            }
        }
        .padding(.horizontal, 32)
    }
}
