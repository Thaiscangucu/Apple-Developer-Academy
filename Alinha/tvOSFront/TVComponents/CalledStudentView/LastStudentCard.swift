//
//  CurrentStudent.swift
//  tvOSFront
//
//  Created by Thais Cangucu on 27/08/25.
//

import SwiftUI
///SwiftUI view that contains the last student called.
///
///Shows the student's name, the mentor who will assist them and the location where they will be assisted.
///
struct LastStudentCard: View {
    
    @Binding var appointments: [GetAppointments]
    @State var calledStudents: [GetAppointments] = []
    @State var backgroundColor: Color = .lightBlue
    @State var textColor: Color = .darkBlueText
    
    var RecWidth: CGFloat = 600
    var RecHeight: CGFloat = 390
    
    var alunoRecWidth: CGFloat = 540
    var alunoRecHeigth: CGFloat = 130
    
    var circleSize: CGFloat = 108
    
    var body: some View {
        ZStack{
            VStack{
                Text("Em atendimento")
                    .font(.system(size: 43, weight: .bold))
                    .foregroundStyle(textColor)
                    .padding(.top, 10)
                // Circulo + Aluno
                ZStack{
                    RoundedRectangle(cornerRadius: 28)
                        .frame(width: alunoRecWidth, height:alunoRecHeigth)
                        .foregroundStyle(.white)
                        .shadow(radius: 6, x: 0, y: 4)
                        .padding(.bottom, 5)
                    HStack(spacing: 50){
                        //Circulo
                        Circle()
                            .frame(width: circleSize, height: circleSize)
                            .foregroundStyle(.studentCardBackground)
                            .padding(.leading, 1)
                        //Aluno + Nome Aluno
                        VStack{
                            Text("Aluno")
                                .foregroundColor(.darkBlueText)
                                .font(.system(size: 28, weight: .regular))
                                .frame(maxWidth: 350, alignment: .leading)
                            
                            Text(calledStudents.last?.studentName ?? "-")
                                .foregroundColor(.black)
                                .font(.system(size: 38, weight: .regular))
                                .frame(maxWidth: 350, alignment: .leading)
                                .lineLimit(1)
                        }
                        .padding(.trailing, -14)
                    }
                    
                }
                // Local + Mentor
                HStack(spacing: 30){
                    SmallRectangle(title: "Local", content: calledStudents.last?.appointmentPlace ?? "-")
                    SmallRectangle(title: "Mentor", content: calledStudents.last?.mentor ?? "-")
                }
                .frame(width: 540)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 32)
        }
        .background{
            RoundedRectangle(cornerRadius: 28)
                .frame(width: RecWidth, height:RecHeight)
                .foregroundStyle(backgroundColor)
        }
        .frame(width: RecWidth, height: RecHeight)
        .onChange(of: appointments.count){
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                backgroundColor = .calledRed
                textColor = .white
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                backgroundColor = .lightBlue
                textColor = .darkBlueText
            }
            calledStudents = appointments.filter(\.callStudent)
            print(appointments)
        }
        
    }
}
