//
//  ListRowView.swift
//  macOSFront
//
//  Created by Francisco Losada on 29/08/25.
//
import SwiftData
import SwiftUI

/// View to see the rows of the queue list
///- Parameter person: The queue of all students
///- Parameter emAtendimento: Select the person that is called
///- Parameter sheetOn: choose if the sheet is on
///- Parameter person: The student thar is on the row of the queue
///- Parameter index: The index of the students queue
///- Parameter role: The role of the user, ADM, Student or Mentor
///- Parameter category: The category of the question
///- Parameter status: The status of the person on the queue
struct ListRowView: View {
    
    @Query var userMac: [User]

    @Binding var appointments: [GetAppointments]
    var appointment: GetAppointments
    //    @Binding var emAtendimento: Person?
    @State var sheetOn = false
    var index: Int
    var pathSelected: String
    var status: String {
        if index == 0 {
            "Atender"
        }
        else {
            "Aguardando"
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 48)
                .foregroundStyle(.darkGreen)
            
            Image(systemName: "person.fill")
                .font(.largeTitle)
                .foregroundStyle(.white)
        }
        .scaledToFit()
        .clipShape(Circle())
        .frame(width: 48)
        .onTapGesture {
            sheetOn.toggle()
        }
        .padding(.leading)
        
        Text(appointment.studentName)
            .font(.headline)
            .fontWeight(.regular)
            .gridColumnAlignment(.leading)
            .padding(.horizontal)
            .foregroundStyle(.black)
            .onTapGesture {
                sheetOn.toggle()
            }
        
        Text(appointment.type)
            .font(.headline)
            .fontWeight(.regular)
            .gridColumnAlignment(.leading)
            .padding(.horizontal)
            .foregroundStyle(.black)
            .onTapGesture {
                sheetOn.toggle()
            }
         
        Text(appointment.description)
            .font(.headline)
            .fontWeight(.regular)
            .gridColumnAlignment(.leading)
            .padding(.horizontal)
            .lineLimit(1)
            .foregroundStyle(.black)
            .onTapGesture {
                sheetOn.toggle()
            }
        
        Text(status)
            .font(.headline)
            .fontWeight(.regular)
            .gridColumnAlignment(.leading)
            .padding(.horizontal)
            .foregroundStyle(.black)
            .onTapGesture {
                sheetOn.toggle()
            }
            .sheet(isPresented: $sheetOn) {
                UserSheetView(appointment: appointment,index: index, pathSelected: pathSelected, appointments: $appointments /*emAtendimento: $emAtendimento*/)
            }
        
        if userMac.first?.role != "User"{
            if status == "Em atendimento" {
                ZStack {
                    Circle()
                        .frame(width: 48)
                        .foregroundStyle(.handColorDark)
                    
                    Image(systemName: "hands.clap.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
                
            }
            else if status == "Atender" {
                Button(action: {
                    if !appointments.isEmpty {
                        Task{
                            do{
                                let patchAppointmentsCallStudent: PatchAppointmentsCallStudent = PatchAppointmentsCallStudent(appointmentId: appointment.id, callStudent: true)
                                
                                 let _ = try await RoutesRequisition.patchAppointmentsCallStudent(object: patchAppointmentsCallStudent, auth: userMac.first!.authID)
                                
                                appointments = try await RoutesRequisition.getAppointments()
                            }
                            catch{
                                print(error.localizedDescription)
                            }
                        }
                        
//                        let filterPerson: [Person] = persons.filter{$0.category == category}
//                        let firstPerson: Person = filterPerson.first!
//                        if let position = persons.firstIndex(where: {$0.id == firstPerson.id}) {
//                            emAtendimento = filterPerson[0]
//                            persons.remove(at: position)
//                        }
                    }
                }, label: {
                    ZStack {
                        Circle()
                            .frame(width: 48)
                            .foregroundStyle(.handColorDark)
                        
                        Image(systemName: "hand.raised.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }
                })
                .buttonStyle(.plain)
            }
            else {
                ZStack {
                    Circle()
                        .frame(width: 48)
                        .foregroundStyle(.handColorLight)
                    
                    Image(systemName: "hand.raised")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
            }
        }
    }
}


