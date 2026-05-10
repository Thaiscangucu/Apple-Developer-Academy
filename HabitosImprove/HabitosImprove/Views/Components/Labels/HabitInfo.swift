//
//  HabitCircle.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 14/07/25.
//

import SwiftUI

struct HabitInfo: View {
    
    // State Properties
    @State var dailyCount: Int16
    @State var goalAlert = false
    @State private var longPressed = false
    
    // Habit Properties
    var habit: Habit
    let characterLimit = 4
    var defaultTime = Date.now
    
    // Services & ViewModel
    let defaults = UserDefaults.standard
    @ObservedObject var viewModel: CoreDataViewModel = CoreDataViewModel()
    
    // Body
    var body: some View {
        ZStack {
            // Background Visual
            Circle()
                .foregroundStyle(.darkerGreen)
                .frame(width: 320, height: 300)
                .opacity(0.7)
                .shadow(color: .sombra, radius: 2, x: 0, y: 4)
            
            VStack {
                // Header: Title
                Text("\(habit.title ?? "")")
                    .font(.system(size: 28, weight: .semibold))
                
                // Controls: Minus, Count, Plus
                HStack {
                    // Minus Button
                    Button {
                        if habit.habitCount != 0 {
                            viewModel.getHabits()
                            dailyCount -= 1
                            habit.totalCount -= 1
                            viewModel.updateHabit(habit: habit, title: habit.title ?? "", descricao: habit.descricao ?? "", goalQuantity: habit.goalQuantity, goalUnit: habit.goalUnit ?? "", reminders: habit.reminders, reminderTime: habit.reminderTime ?? defaultTime, newCount: dailyCount, totalCount: habit.totalCount)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.plusButton)
                            .opacity(0.5)
                    }
                    .buttonRepeatBehavior(.enabled)
                    
                    // Display Current Progress
                    Text("\(dailyCount)/\(habit.goalQuantity)")
                        .fixedSize(horizontal: true, vertical: true)
                        .font(.system(size: 50))
                    
                    // Plus Button
                    Button {
                        viewModel.getHabits()
                        dailyCount += 1
                        habit.totalCount += 1
                        checkGoal()
                        viewModel.updateHabit(habit: habit, title: habit.title ?? "", descricao: habit.descricao ?? "", goalQuantity: habit.goalQuantity, goalUnit: habit.goalUnit ?? "", reminders: habit.reminders, reminderTime: habit.reminderTime ?? defaultTime, newCount: dailyCount, totalCount: habit.totalCount)
                        checkStreak()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.plusButton)
                            .opacity(0.5)
                    }
                    .buttonRepeatBehavior(.enabled)
                }
                
                // Footer: Unit and Quick Add
                Text(LocalizedStringKey(habit.goalUnit ?? ""))
                    .fontDesign(.rounded)
                
                Button {
                    dailyCount += 10
                    habit.totalCount += 10
                    viewModel.updateHabit(habit: habit, title: habit.title ?? "", descricao: habit.descricao ?? "", goalQuantity: habit.goalQuantity, goalUnit: habit.goalUnit ?? "", reminders: habit.reminders, reminderTime: habit.reminderTime ?? defaultTime, newCount: dailyCount, totalCount: habit.totalCount)
                    checkGoal()
                    checkStreak()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 50)
                            .frame(width: 60, height: 40)
                            .foregroundStyle(.plusButton)
                            .opacity(0.5)
                        Text("+10")
                            .fontWeight(.heavy)
                            .foregroundStyle(.darkerGreen)
                    }
                }
                .padding(.top)
            }
            .padding(.top, 50)
        }
        .alert("Congratulations! 🎉 \nYou achieved your daily goal!\nKeep up the great work!", isPresented: $goalAlert) {
            Button("OK") { }
        }
        .onAppear {
            viewModel.getHabits()
            viewModel.getDays()
            viewModel.getStreaks()
            checkDayIsDone()
            checkAndReset()
        }
    }
    
    // MARK: - Helper Functions
    
    /// Checks if the date has changed and resets the daily count if needed.
    func checkAndReset() {
        let lastSavedDate = defaults.object(forKey: "lastSavedDate") as? Date ?? Date.distantPast
        let isToday = Calendar.current.isDateInToday(lastSavedDate)
        
        if !isToday {
            viewModel.zeroDailyCount()
            defaults.set(Date(), forKey: "lastSavedDate")
            dailyCount = 0
        }
    }
    
    /// Updates the visual representation of the day (color) based on progress.
    func checkDayIsDone() {
        for day in viewModel.days {
            if habit.title == day.habit, let date = day.date {
                if Date.now.startOfDay == date.startOfDay {
                    let color = habit.habitCount > 0 ? "verde" : "cinza"
                    viewModel.updateDay(day: day, dailyCount: habit.habitCount, date: date, color: color)
                }
            }
        }
    }
    
    /// Calculates the average progress for this habit across all logged days.
    func getAverage() -> Int16 {
        let doneDays = viewModel.days.filter { $0.habit == habit.title && $0.color == "verde" }
        guard !doneDays.isEmpty else { return habit.totalCount }
        return habit.totalCount / Int16(doneDays.count)
    }
    
    /// Triggers the celebration alert if the goal is met.
    func checkGoal() {
        if dailyCount == habit.goalQuantity {
            goalAlert.toggle()
        }
    }
    
    /// Validates and increments the user's streak if a new day has started.
    func checkStreak() {
        for streak in viewModel.streaks {
            if let date = streak.date {
                if Date.now.startOfDay == date.startOfDay {
                    return
                } else {
                    viewModel.increaseStreak()
                    streak.date = Date.now
                }
            }
        }
        viewModel.getStreaks()
    }
}
