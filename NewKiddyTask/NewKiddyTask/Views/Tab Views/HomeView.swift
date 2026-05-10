//
//  HomeView1.swift
//  NewKiddyTask
//
//  Created by Camila Parolin on 01/02/26.
//

import SwiftUI



struct HomeView: View {
    var guardian: CGFloat = 50.0
    @State var newTaskSheet = false
    @AppStorage("kidName") var kidName: String = ""
    @Environment(\.dismiss) var dismiss
    
    var viewModel: CoreDataViewModel
    var body: some View {
        
        NavigationStack {
            ZStack {
                // Background image
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    
                    // Tool bar
                    HStack{
                        NavigationLink{
                            RewardsView(viewModel: viewModel)
                        }label:{
                            Image("Trophy")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        Spacer()
                        NavigationLink(destination: GuardianView(viewModel: viewModel)) {
                            Image("GuardianTB")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        //                    .offset(x: 165, y: 365)
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    
                    // Texto de boas-vindas
                    HStack(spacing: 0){
                        Text("Essas são suas tarefas,")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundStyle(.textGray)
                        Text("\(kidName)!")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("cinza1"))
                    }
                    .padding(.top)
                    
                    
                    // Para hoje, data e botão +
                    HStack{
                        VStack(alignment: .leading) {
                            Text("Para hoje,")
                                .font(.system(size: 20, design: .rounded))
                                .foregroundStyle(Color("cinza1"))
                            Text("\(Date.now, format: .dateTime.day().month(.wide)).")
                                .font(.system(size: 26, design: .rounded))
                                .foregroundStyle(Color("cinza1"))
                        }
                        Spacer()
                        
                        // Botão +
                        Button {
                            newTaskSheet.toggle()
                        }
                        label: {
                            ZStack {
                                Image("PlusCircle")
                                    .resizable()
                                    .frame(width: 42, height: 42)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 29))
                                    .foregroundStyle(Color("plusColor"))
                            }
                        }
                        .sheet(isPresented: $newTaskSheet, onDismiss: {
                            viewModel.getTarefas()
                        }) {
                            NewTaskForm(isShowingSheet: $newTaskSheet, viewModel: viewModel)
                        }
                    }
                    .frame(width: 260   , height: 90)
                    
                    // Scrollview com  tarefas
                    ScrollView (.horizontal, showsIndicators: false) {
                        if viewModel.tarefas.isEmpty{
                            Image("noTask")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 272, height: 388)
                                .containerRelativeFrame(.horizontal)
                        }
                        else{
                            HStack {
                                ForEach(viewModel.tarefas, id: \.objectID){ task in
                                    TaskCard(viewModel: viewModel, task: task)
                                        .containerRelativeFrame(.horizontal, count: 1, spacing: 16)
                                        .scrollTransition { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1 : 0.46)
                                                .scaleEffect(x: phase.isIdentity ? 1 : 0.7, y: phase.isIdentity ? 1 : 0.7)
                                            
                                        }
                                }
                            }
                            .scrollTargetLayout()
                        }
                    }
                    .contentMargins(70, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .padding(.top, -40)
                }
                .padding(.bottom, 95)
            }
            .onAppear{
                viewModel.getTarefas()
            }
        }
        
    }
}

//#Preview {
//    HomeView()
//}
