//
//  ContentView.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//

import SwiftUI

struct ContentView: View {
    
    @State var viewModel: CoreDataViewModel =  CoreDataViewModel()
    
    @AppStorage("firstTime") var firstTime = true
    //    @State var firstTime = true
    @State private var selectedTab = 0
    @State var test = ""
    
    var body: some View {
        
        if !firstTime{
            NavigationStack{
                ZStack{
                    TabView {
                        HomeView(viewModel: viewModel)
                            .tabItem {
                                Image(systemName: "house")
                                Text("menu")
                            }
                        MemoriasView(viewModel: viewModel)
                            .tabItem {
                                Image(systemName: "books.vertical")
                                Text("memórias")
                            }
                        
                        ConexaoView()
                            .tabItem {
                                Image(systemName: "puzzlepiece")
                                Text("conexão")
                            }
                    }
                    
                    
                }
            }
            .onAppear {
                NotificationManagerModel.requirePermissions()
            }
        }
        else{
            WelcomeView(firstTime: $firstTime)
        }
        
    }
}

#Preview {
    ContentView()
}
