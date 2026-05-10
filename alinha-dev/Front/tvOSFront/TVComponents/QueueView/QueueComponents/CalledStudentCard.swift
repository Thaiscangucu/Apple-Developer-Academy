//
//  CurrentStudentCard.swift
//  tvOSFront
//
//  Created by Thais Cangucu on 28/08/25.
//

import SwiftUI
///The tvOS SwiftUI component of each queue member.
///
///Shows the student's name, the mentor who will assist him and the place where they  will be assisted.

struct CalledStudentCard: View {
    var appointment: GetAppointments
    
    @State var student: GetUser = GetUser()
    
    var RecWidth: CGFloat = 270
    var RecHeight: CGFloat = 120

    var CircleSize: CGFloat = 74
    
    var fontSize: CGFloat = 24
    
    var body: some View {
        HStack(spacing: 10){
            Circle()
//                .foregroundStyle(.iconCircle)
                .foregroundStyle(.studentCardBackground)
                .frame(width: CircleSize, height: CircleSize)
            VStack(alignment: .leading){
                Text(appointment.studentName)
                    .foregroundColor(.black)
                    .font(.system(size: fontSize, weight: .bold))
                    .frame(width: 170, alignment: .leading)
                    .lineLimit(1)
                Text(appointment.appointmentPlace)
                    .foregroundColor(.black)
                    .font(.system(size: 22, weight: .regular))
                    .frame(width: 170, alignment: .leading)
                    .lineLimit(1)

                Text(appointment.mentor)
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .regular))
                    .frame(width: 170, alignment: .leading)
                    .lineLimit(1)
                    .italic()
            }

        }
        .padding(8)
        .background{
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.white)
                .frame(width: RecWidth, height: RecHeight)
                .shadow(radius: 6, x: 0, y: 4)
        }
//        .onAppear{
//            Task{
//                do{
//                    student = try await RoutesRequisition.getUsersId(id: appointment.student)
//                }catch {
////                    print(error.localizedDescription)
//                }
//            }
//        }
    }
}

//#Preview {
//    CalledStudentCard(mentor: "Joaquim", local: "Boardroom", student: "Ana Carolina")
//}
