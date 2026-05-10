//
//  MacQueueView.swift
//  macOSFront
//
//  Created by Francisco Losada on 25/08/25.
//
import SwiftData
import SwiftUI

/// This is a show if is a student or a mentor
struct MacQueueView: View {
    
    @Query var userMac: [User]
    
    @State var selectedBarItem: SideBarItem = .queue
    let timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()

    @State var isOnSheet: Bool = false
    @State var showAlert: Bool = false
    
    @State var appointments: [GetAppointments] = []
    
    var body: some View {
        ZStack{
            Color.ligthYellow
            Image("Background")
                .resizable()
            
            VStack {
                if userMac.first?.role == "student" {
                    MacQueueUserView(appointments: $appointments)
                        .toolbar{
                            ToolbarItem(placement: .confirmationAction){
                                Button(action:{
                                    isOnSheet = true
                                })
                                {
                                    Image(systemName: "plus.bubble.fill")
                                        .font(.title2)
                                        .padding(.horizontal, 66)
                                }
                            }
                            
                        }
                    
                }
                else if userMac.first?.role == "mentor" {
                    MacQueueUserView(appointments: $appointments)
                        .toolbar{
                            ToolbarItem{
                                MacOSQueueMentorToolbar()
                            }
                        }
                }
                else{
                    MacQueueUserView(appointments: $appointments)
                        .toolbar{
                            ToolbarItem{
                                MacOSQueueMentorToolbar()
                                
                            }
//                            ToolbarItem{
//                                Button(role: .destructive, action: {
//                                    showAlert.toggle()
//                                }, label: {
//                                    Image(systemName: "trash")
//                                        .foregroundStyle(.red)
//                                })
//                                .alert("Você quer mesmo limpar a fila?", isPresented: $showAlert, actions: {
//                                    Button("Limpar fila", role: .destructive){person.removeAll()}
//                                    Button("Cancelar", role: .cancel){}
//                                })
//                            }
                            
                        }
                }
            }
            .background(Color.background)
            .toolbarBackground(.handColorLight)
            .onReceive(timer){_ in
                Task{
                    do{
                        appointments = try await RoutesRequisition.getAppointments()
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .sheet(isPresented: $isOnSheet){
            MacQueueAddSheetView(appointments: $appointments)
        }
    }
    
}

#Preview {
    MacQueueView()
}
