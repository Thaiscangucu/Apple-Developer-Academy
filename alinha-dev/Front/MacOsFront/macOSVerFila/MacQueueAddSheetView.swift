//
//  MacQueueAddSheetView.swift
//  macOSFront
//
//  Created by Francisco Losada on 21/08/25.
//

import SwiftUI
import SwiftData
///View for showing the sheet to enter the queue on macOS
/// - Parameter name: this is a name that user insert
/// - Parameter category: this is a categoy that user select
/// - Parameter problem: this is a problem that user select
/// - Parameter desc: this is a desc of requisition
/// - Parameter person: this is a array of person properties
/// - Parameter categories: this categories is a array that user select
/// - Parameter problems: this is problem array that user select
struct MacQueueAddSheetView: View{
    @Query var userMac: [User]
    
    @Environment(\.dismiss) var dismiss
    @State var postAppointments: PostAppointments = PostAppointments()
    
    @State var name: String =  "UserName"
    @State var category: String = "Código"
    @State var problem: String = "Problema"
    @State var desc: String =  ""
    @Binding var appointments: [GetAppointments]
    
    let categories: [String] = ["code", "design", "undefined"]
    let problems: [String] = ["doubt", "problem"]
    
    var body: some View {
        Spacer()
        
        VStack(alignment: .leading){
            HStack {
                Text("UserName")
                .padding(.horizontal)
                .font(.title2)
                .bold()
                
                Spacer()
                
                Button {
                    Task{
                        if (postAppointments.description != "" && postAppointments.type != "" && postAppointments.path != ""){
                            do{
                                postAppointments.student = userMac.first!.name
                                let _ = try await RoutesRequisition.postAppointments(object: postAppointments)
                                appointments = try await RoutesRequisition.getAppointments()
                            }
                            catch{
                                print(error.localizedDescription)
                            }
                        }
                    }
                    dismiss()
                } label: {
                    Text("Entrar")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .background(Color.picker)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            HStack {
                Picker("", selection: $postAppointments.path) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }

                Picker("", selection: $postAppointments.type) {
                    ForEach(problems, id: \.self) { problem in
                        Text(problem)
                    }
                }
                
                Rectangle()
                    .frame(width: 95, height: 11)
                    .foregroundStyle(.clear)
                
                Spacer()
            }
            .padding(.horizontal)

            TextField("Descrição", text: $postAppointments.description, axis: .vertical)
            .lineSpacing(8)
            .lineLimit(12)
            .padding(.horizontal)
            .textFieldStyle(.plain)
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(width: 400, height: 280)
        Spacer()
    }
}
