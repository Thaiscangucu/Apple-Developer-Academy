//
//  AllHabitsComponent.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 14/07/25.
//

import SwiftUI

struct AllHabits: View {
    
    @ObservedObject private var viewModel: CoreDataViewModel = CoreDataViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Background()
                    .ignoresSafeArea()
                
                if viewModel.habits.isEmpty {
                    emptyStateView
                }
                
                List {
                    ForEach(viewModel.habits, id: \.id) { habit in
                        HabitRow(habit: habit, viewModel: viewModel)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.automatic)
                .opacity(0.80)
            }
            .navigationTitle("All Habits")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                fetchInitialData()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Text("No habits here.")
            Text("Create a new one to start 🚀")
        }
    }
    
    // MARK: - Logic Functions
    
    /// Fetches all necessary data from Core Data when the view loads.
    private func fetchInitialData() {
        viewModel.getHabits()
        viewModel.getDays()
    }
}


struct HabitRow: View {
    
    let habit: Habit
    @ObservedObject var viewModel: CoreDataViewModel
    
    var body: some View {
        NavigationLink {
            HabitPage(habit: habit)
        } label: {
            ListItem(title: habit.title ?? "")
        }
        .swipeActions {
            deleteButton
        }
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            handleDelete()
        } label: {
            Image(systemName: "trash")
        }
    }
    
    // MARK: - Logic Functions
    
    /// Clears associated records and deletes the habit from the database.
    private func handleDelete() {
        viewModel.clearDays(habit: habit.title ?? "")
        viewModel.deleteHabit(habit: habit)
        viewModel.getHabits()
    }
}

#Preview {
    AllHabits()
}
