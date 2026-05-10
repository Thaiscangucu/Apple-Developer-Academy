//
//  HomePage.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 14/07/25.
//

//TODO: Create quick tutorial when app opens for the first time
//TODO: Create Widget
//TODO: Create Lauch Screen
//TODO: Show diferent tons of green depending of the habit count
//TODO: Linkar com app saúde
//TODO: Clicar no calendário e abrir uma tela com todos os meses
//TODO: Permitir mudar os habitos de posição

import SwiftUI

struct HomePage: View {
    
    let defaults = UserDefaults.standard
    @StateObject var viewModel: CoreDataViewModel = CoreDataViewModel()
    @AppStorage("isStreakCreated") private var isStreakCreated = false
    var dateNow = Date.now

    var body: some View {
        NavigationStack {
            ZStack {
                Background()
                VStack {
                    HStack {
                        NavigationLink {
                            StreakPage(viewModel: viewModel)
                        } label: {
                            StreakCount(viewModel: viewModel)
                        }
                        
                        Spacer()
                        
                        PlusButton(type: .regular, viewModel: viewModel)
                            .padding(.trailing)
                        
                        ListButton()
                    }
                    .padding()
                    
                    Today()
                    
                    if viewModel.habits.isEmpty {
                        ZStack {
                            Circle()
                                .foregroundStyle(.darkerGreen)
                                .frame(width: 320, height: 300)
                                .opacity(0.7)
                                .shadow(color: .sombra, radius: 2, x: 0, y: 4)
                            VStack{
                                Text("Tap the + to create")
                                Text("a new habit.")
                            }
                        }
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(viewModel.habits.reversed(), id: \.id) { habit in
                                    NavigationLink {
                                        HabitPage(habit: habit)
                                    } label: {
                                        HabitInfo(dailyCount: habit.habitCount, habit: habit)
                                            .foregroundStyle(.text)
                                            .fontDesign(.rounded)
                                    }
                                }
                                
                                PlusButton(type: .circle, viewModel: viewModel)
                            }
                            .padding(.bottom)
                            .padding(.leading, 42)
                        }
                        .scrollIndicators(.hidden)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.getStreaks()
            viewModel.getHabits()
            viewModel.getDays()
            checkAndReset()
            createStreak()
            isYesterdayDone()
        }
    }

    // MARK: - Functions
    
    /// Resets the daily count for all habits if a new day has started.
    func checkAndReset() {
        let lastSavedDate = defaults.object(forKey: "lastSavedDate") as? Date ?? Date.distantPast
        let isToday = Calendar.current.isDateInToday(lastSavedDate)
        
        if !isToday {
            viewModel.zeroDailyCount()
            defaults.set(Date(), forKey: "lastSavedDate")
        }
    }
    
    /// Ensures the initial streak record is created in Core Data.
    func createStreak() {
        if isStreakCreated == false {
            viewModel.createStreak()
            isStreakCreated = true
        }
    }
    
    /// Checks if the user completed their habits yesterday to maintain the streak.
    /// - Returns: Boolean indicating if yesterday's habits were completed.
    @discardableResult
    func isYesterdayDone() -> Bool {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        var allYesterdays: [Day] = []
        
        for day in viewModel.days {
            if let date = day.date, calendar.isDate(date, inSameDayAs: yesterday) {
                allYesterdays.append(day)
            }
        }
        
        for yesterday in allYesterdays {
            if yesterday.color == "verde" {
                return true
            } else {
                viewModel.resetStreak()
                return false
            }
        }
        return false
    }
}

#Preview {
    HomePage()
}
