//
//  ContentView.swift
//  EventsApp
//
//  Created by Thais Cangucu on 11/08/26.
//

import SwiftUI
import SwiftData

// MARK: - Rotas
enum Rota: Hashable {
    case users
    case bill(autoOpenForm: Bool = false)
    case split
    case total
    case card
    case history
    case historyDetail(SavedBill)
}

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var billVm = BillViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack(path: $path) {
            AddUsersView(path: $path)
                .navigationDestination(for: Rota.self) { rota in
                    switch rota {
                    case .users:
                        AddUsersView(path: $path)
                    case .bill(let autoOpenForm):
                            BillView(path: $path, autoOpenForm: autoOpenForm)
                    case .split:
                        SplitView(path: $path)
                    case .total:
                        TotalView(path: $path)
                    case .card:
                        CardView(path: $path)
                    case .history:
                        HistoryView(path: $path)
                    case .historyDetail(let savedBill):
                        HistoryDetailView(savedBill: savedBill)
                    }
                }
                .task {
                    // Respeita o botão de notificações dos ajustes do app:
                    // desligado, garante que nada fique agendado; ligado (ou
                    // primeira abertura), pede permissão se preciso e agenda.
                    if NotificationManagerModel.isEnabledInApp {
                        NotificationManagerModel.requirePermissions()
                    } else {
                        NotificationManagerModel.disableNotifications()
                    }
                }
        }
        .environment(billVm)
        .onAppear {
            billVm.setModelContext(modelContext)
        }
    }
}

#Preview{
    ContentView()
}
