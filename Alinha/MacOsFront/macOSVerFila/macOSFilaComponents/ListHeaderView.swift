//
//  ListHeaderView.swift
//  macOSFront
//
//  Created by Francisco Losada on 29/08/25.
//

import SwiftUI
import SwiftData
///View that organize the header of the queue and filter the path of the question
///- Parameter person: The queue of all students
///- Parameter calledPerson: The student that was called
///- Parameter pathSelected: Selection between Code, Design and Other
///- Parameter role: The role of the user, ADM, Student or Mentor
struct ListHeaderView: View {
    
    @Query var userMac: [User]
    @Binding var appointments: [GetAppointments]
    var pathSelected: String
    
    var body: some View {
        ScrollView {
            VStack{
                Grid {
                    GridRow {
                        Circle()
                            .frame(width: 30)
                            .foregroundStyle(.clear)
                            .gridColumnAlignment(.leading)
                            .padding(.horizontal)
                        
                        Text("Nome")
                            .font(.headline)
                            .fontWeight(.regular)
                            .gridColumnAlignment(.leading)
                            .padding(.horizontal)
                        
                        Text("Categoria")
                            .font(.headline)
                            .fontWeight(.regular)
                            .gridColumnAlignment(.leading)
                            .padding(.horizontal)
                        
                        HStack{
                            Text("Descrição")
                                .font(.headline)
                                .fontWeight(.regular)
                                .gridColumnAlignment(.leading)
                            Text("xxxxxx;l;l;l;lxl;xlc;xlc;x;c;xc;x;clxl;clx;cl;xcl;xcl;cl;l;l;")
                                .foregroundStyle(.clear)
                        }
                        .padding(.horizontal)
                        
                        Text("Status")
                            .font(.headline)
                            .fontWeight(.regular)
                            .gridColumnAlignment(.leading)
                            .padding(.horizontal)
                        
                        Text("")
                            .padding(.horizontal)
                    }
                    .foregroundStyle(.handColorLight)
                    .frame(height: 30)
                    
                    if appointments.filter({$0.path == pathSelected}).isEmpty /*&& calledPerson == nil*/{
                        Divider()
                            .frame(maxWidth: 3000)
                        GridRow{
                            Circle()
                                .strokeBorder(style: StrokeStyle(dash: [5]))
                                .frame(width: 48)
                                .foregroundStyle(.handColorLight)
                        }
                        .frame(height: 76)
                    }
                    else{
                        //                    if calledPerson != nil {
                        //                        Divider()
                        //                            .frame(maxWidth: 3000)
                        //                            .foregroundStyle(.handColorLight)
                        //                        GridRow {
                        //                            macOSemAtendimentoView(person: calledPerson)
                        //                        }
                        //                    }
                        
                        ForEach(Array(appointments.filter{$0.path == pathSelected}.enumerated()), id:\.element.id){ index, appointment in
                            Divider()
                                .frame(maxWidth: 3000)
                                .foregroundStyle(.handColorLight)
                            GridRow {
                                ListRowView(appointments: $appointments, appointment: appointment, index: index, pathSelected: pathSelected)
                            }
                            .frame(height: 76)
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(.white))
                .padding(.horizontal, 66)
                .padding(.vertical)
                Spacer()
                
                if appointments.filter({$0.path == pathSelected}).isEmpty /*&& calledPerson == nil*/{
                    MacOSEmptyQueue()
                }
                Spacer()
            }
        }
    }
}
