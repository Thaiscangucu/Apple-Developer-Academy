//
//  MemoriasView.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//

import SwiftUI

struct PageView: View {
    var viewModel: CoreDataViewModel
    @State private var currentIndex = 0
    
    var body: some View {
        let completedTasks = viewModel.tarefas.filter { $0.done }
        ZStack{
            // Background image
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Image("openBook")
                .resizable()
                .scaledToFit()
                .frame(width: 365, height: 516)
                .padding(.trailing, 40)
            
            // ScrollView
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        let completedTasks = viewModel.tarefas.filter { $0.done }
                        
                        // Use o enumerado para ter o INDEX numérico para o ScrollTo
                        ForEach(Array(completedTasks.enumerated()), id: \.element.objectID) { index, task in
                            doneTaskPage(doneTask: task)
                                .containerRelativeFrame(.horizontal)
                                .id(index)
                        }
                    }
                }
                .scrollDisabled(true)
                .frame(width: 240)
                
                // Botões < >
                HStack {
                    Button(action: {
                        if currentIndex > 0 {
                            currentIndex -= 1
                            withAnimation {
                                proxy.scrollTo(currentIndex, anchor: .center)
                            }
                        }
                    }) {
                        Image(systemName: "chevron.backward.circle")
                    }
                    .disabled(currentIndex == 0)
                    .opacity(currentIndex == 0 ? 0.3 : 1.0)

                    Spacer()

                    Button(action: {
                        if currentIndex < completedTasks.count - 1 {
                            currentIndex += 1
                            withAnimation {
                                proxy.scrollTo(currentIndex, anchor: .center)
                            }
                        }
                    }) {
                        Image(systemName: "chevron.forward.circle")
                    }
                    .disabled(currentIndex >= completedTasks.count - 1 || completedTasks.isEmpty)
                    .opacity(currentIndex >= completedTasks.count - 1 || completedTasks.isEmpty ? 0.3 : 1.0)
                }
                .font(.system(size: 35, weight: .medium))
                .foregroundColor(Color(red: 0.44, green: 0.57, blue: 1))
                .frame(width: 240)
                
            
            }
            .padding(.bottom, 25)
            .padding(.leading, 15)
        }
    }
}

