//
//  UserSheetView.swift
//  macOSFront
//
//  Created by anshu Li on 02/09/25.
//
import SwiftData
import SwiftUI

///View for showing the sheet about complete description of the user
/// - Parameter role: this is a role that selected by user
/// - Parameter person: this is a person that clicked by user
/// - Parameter index: this is a person index that selected by user
/// - Parameter category: this is category that selected by user
/// - Parameter person: this is list of person storyed
/// - Parameter emAtendimento: this is a person that called by mentor
struct UserSheetView: View {
    
    var appointment: GetAppointments
    var index: Int
    var pathSelected: String
    @Binding var appointments: [GetAppointments]
    @Query var userMac: [User]

//    @Binding var emAtendimento: Person?
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                VStack(alignment: .leading){
                    Text(appointment.studentName)
                        .font(.title3)
                        .bold()
                    Text(appointment.type)
                        .font(.subheadline)
                }
                
                Spacer()
                
                if userMac.first?.role != "student"{
                    Button(action: {
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
//                        if !persons.isEmpty{
//                            let filterPerson: [Person] = persons.filter{$0.category == category}
//                            let selectedPerson: Person = filterPerson[index]
//                            
//                            if let position = persons.firstIndex(where: {$0.id == selectedPerson.id}){
//                                emAtendimento = filterPerson[index]
//                                persons.remove(at: position)
//                            }
//                        }
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
            }
            
            Text(appointment.description)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: 400, maxHeight: 3000)
        
        Spacer()
    }
}


//    #Preview {
//        UserSheetView()
//    }
