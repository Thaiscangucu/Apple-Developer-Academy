//
//  StudentCard.swift
//  tvOSFront
//
//  Created by Thais Cangucu on 28/08/25.
//

import SwiftUI
///SwiftUI view in QueueView page, that contains the student's name and icon.
struct StudentCard: View {
    
    var appointment: GetAppointments
    @State var student: GetUser = GetUser()
    
    var RecWidth: CGFloat = 240
    var RecHeight: CGFloat = 80
    var CircleSize: CGFloat = 60
    
    var fontSize: CGFloat = 24
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .frame(width: RecWidth, height: RecHeight)
                .foregroundStyle(.studentCardBackground)
                .shadow(radius: 6, x: 0, y: 2)
            HStack(spacing: 0){
                Circle()
//                    .foregroundStyle(.iconCircle)
                    .foregroundStyle(.studentCardBackground)
                    .frame(width: CircleSize, height: CircleSize)
                    .padding(.trailing)
                
                Text(appointment.studentName)
                    .foregroundColor(.black)
                    .font(.system(size: fontSize, weight: .regular))
                    .frame(width: 120, alignment: .leading)
                    .lineLimit(1)
                
            }
            .frame(width: 200)
        }
//        .onAppear{
//            Task{
//                do{
//                    student = try await RoutesRequisition.getUsersId(id: appointment.student)
////                    print(student)
//                }catch {
//                    print(error.localizedDescription)
//                }
//            }
//        }
    }
}
//
//#Preview {
//    StudentCard(appointment: )
//}
