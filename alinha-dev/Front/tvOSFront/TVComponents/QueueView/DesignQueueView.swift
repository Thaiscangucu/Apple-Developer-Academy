//
//
//  Queue.swift
//  tvOSFront
//
//  Created by Yasmin Mendes  on 28/08/25.
//

import SwiftUI
///SwftUI view that contains the students queue.
///
///Creates design students queue with all the correspondent students.
struct DesignQueueView: View {
    
    var path: String
    
    @Binding var appointments: [GetAppointments]
    @State var designStudents: [GetAppointments] = []
    
    var body: some View {
        VStack(spacing: 10){
                Text("Design")
                    .foregroundColor(.darkBlueText)
                    .font(.system(size: 43, weight: .bold))
                    .padding(.bottom, 20)
            if designStudents.isEmpty{
                BlankStudentCard()
            }
            else{
                VStack(spacing: -20){
                    ForEach(Array(designStudents.enumerated()), id: \.element.id) { index, appointment in
                        if appointment.path == "design"{
                            StudentCard(appointment: appointment)
                                .zIndex(Double(appointments.count - index))
                        }
                    }
                }
            }
        }
        .padding(.vertical)
        .frame(width: 300)
        .frame(minHeight: 150)
//        .frame(maxHeight: 980)
        
        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(.lightBlue)
                .frame(maxHeight: 980)
        )
        .onChange(of: appointments.count){
            designStudents = appointments.filter{
                $0.path == "design"
            }
        }
    }
}
