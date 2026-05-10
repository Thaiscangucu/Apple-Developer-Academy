//
//  Queue.swift
//  tvOSFront
//
//  Created by Yasmin Mendes  on 28/08/25.
//

import SwiftUI
///SwftUI view that contains the students queue.
///
///Creates code students queue with all the correspondent students.
struct CodeQueueView: View {
    var path: String
    @Binding var appointments: [GetAppointments]
    @State var codeStudents: [GetAppointments] = []
    
    var body: some View {
        VStack(spacing: 10){
            Text("Código")
                .foregroundColor(.darkBlueText)
                .font(.system(size: 43, weight: .bold))
                .padding(.bottom, 20)
            if codeStudents.isEmpty{
                BlankStudentCard()
            }
            else{
                VStack(spacing: -20){
                    ForEach(Array(codeStudents.enumerated()), id: \.element.id) { index, appointment in

                            // If student is being called, CalledStudentCard shows up
                            if appointment.callStudent == true{
                                CalledStudentCard(appointment: appointment)
                                    .zIndex(Double(appointments.count - index))
                            }
                            // If not, just plain StudentCard appears
                            else{
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

        .background(
            RoundedRectangle(cornerRadius: 30)
                .foregroundStyle(.lightBlue)
                .frame(maxHeight: 980)
        )
        .onChange(of: appointments.count){
            codeStudents = appointments.filter{
                $0.path == "code"
            }
        }
        
    }
}
