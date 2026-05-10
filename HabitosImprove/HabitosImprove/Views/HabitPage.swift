//
//  Habit.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 14/07/25.
//

import SwiftUI

struct HabitPage: View {
    
    @ObservedObject var viewModel: CoreDataViewModel = CoreDataViewModel()
    @State var dateNow = Date.now
    @State var isShowing = false
    @State var days: [Date] = []
    
    var dayInitials: [String] {
        let formatter = DateFormatter()
        return formatter.veryShortStandaloneWeekdaySymbols
    }
    
    let columns = Array(repeating: GridItem(.fixed(20)), count: 7)
    var habit: Habit
    
    var body: some View {
        ZStack {
            Background()
            VStack {
                Spacer()
                
                // Main Info Section
                VStack {
                    Text("\(habit.title ?? "")")
                        .font(.system(size: 28, weight: .semibold))
                    Text("\(habit.descricao ?? "")")
                        .font(.subheadline)
                    Text("\(habit.habitCount)")
                        .font(.system(size: 66))
                    Text(LocalizedStringKey(habit.goalUnit ?? ""))
                }
                .fontDesign(.rounded)
                
                Spacer()
                
                // Habit Stats List
                VStack(alignment: .leading, spacing: 8) {
                    HabitStat(statTitle: "Today:", count: habit.habitCount, unit: LocalizedStringKey(habit.goalUnit ?? ""))
                    HabitStat(statTitle: "Total:", count: habit.totalCount, unit: LocalizedStringKey(habit.goalUnit ?? ""))
                    HabitStat(statTitle: "Average:", count: getAverage(), unit: LocalizedStringKey(habit.goalUnit ?? ""))
                }
                .fontDesign(.rounded)
                
                Spacer()
                
                // Pixel Calendar Section
                ZStack {
                    CalendarBackground()
                    VStack {
                        MonthName(month: dateNow.formatted(.dateTime.month(.wide)).capitalized)
                        
                        VStack(spacing: 1) {
                            // Weekdays Header
                            HStack(spacing: 19) {
                                ForEach(dayInitials, id: \.self) { initial in
                                    Text(initial)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                            }
                            .fontDesign(.rounded)
                            .padding(.top)

                            // Pixels Grid
                            LazyVGrid(columns: columns, spacing: 3) {
                                ForEach(days, id: \.self) { date in
                                    let habitStatus = viewModel.days.first { day in
                                        guard let dayDate = day.date else { return false }
                                        return Calendar.current.isDate(dayDate, inSameDayAs: date) && day.habit == habit.title
                                    }
                                    
                                    if Calendar.current.isDate(date, equalTo: dateNow, toGranularity: .month) {
                                        Pixel(day: Calendar.current.component(.day, from: date),
                                              color: habitStatus?.color ?? "cinza")
                                    } else {
                                        Color.clear
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                        }
                        .frame(width: 230)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .ignoresSafeArea()
                                .foregroundStyle(.lightBeige)
                        )
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isShowing.toggle()
                }
                .sheet(isPresented: $isShowing) {
                    HabitFormView(viewModel: viewModel, mode: .edit(habit))
                        .presentationDetents([.large])
                }
            }
        }
        .onAppear {
            viewModel.getHabits()
            viewModel.getDays()
            checkDayIsDone()
            days = dateNow.calendarDisplayDays
            createMoreDays()
        }
    }
    
    // MARK: - Functions
    
    /// Checks if there was interaction with the habit today and updates its status in the database.
    func checkDayIsDone() {
        for day in viewModel.days {
            if habit.title == day.habit {
                if let date = day.date {
                    if Date.now.startOfDay == date.startOfDay {
                        let color = habit.habitCount > 0 ? "verde" : "cinza"
                        viewModel.updateDay(day: day, dailyCount: habit.habitCount, date: date, color: color)
                    }
                }
            }
        }
    }
    
    /// Calculates the average progress per day based on completed entries.
    /// - Returns: The average quantity as an Int16.
    func getAverage() -> Int16 {
        let doneDays = viewModel.days.filter { $0.habit == habit.title && $0.color == "verde" }
        
        if !doneDays.isEmpty {
            return habit.totalCount / Int16(doneDays.count)
        } else {
            return habit.totalCount
        }
    }
    
    /// Ensures calendar days are created in the database as time progresses.
    func createMoreDays() {
        for day in days {
            guard !viewModel.dayExists(habit: habit.title ?? "", date: day) else { continue }
            
            viewModel.createDay(
                habit: habit.title ?? "",
                date: day,
                color: "cinza"
            )
        }
    }
}

#Preview {
    ContentView()
}
