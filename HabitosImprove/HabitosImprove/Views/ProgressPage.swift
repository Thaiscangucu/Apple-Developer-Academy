//
//  ProgressPage.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 15/07/25.
//

import SwiftUI

struct ProgressPage: View {
    
    @StateObject private var viewModel: CoreDataViewModel = CoreDataViewModel()
    @State public var dateNow = Date.now
    @State var days: [Date] = []
    
    var dayInitials: [String] {
        let formatter = DateFormatter()
        return formatter.veryShortStandaloneWeekdaySymbols
    }
    
    let columns = Array(repeating: GridItem(.fixed(20)), count: 7)
    
    init() {
        let appearance = UINavigationBarAppearance()
        
        // Criando a fonte arredondada para o Título Grande
        let largeDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
            .withDesign(.rounded)?
            .withSymbolicTraits(.traitBold) ?? .preferredFontDescriptor(withTextStyle: .largeTitle)
        
        // Criando a fonte arredondada para o Título Pequeno (quando rola a tela)
        let inlineDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
            .withDesign(.rounded)?
            .withSymbolicTraits(.traitBold) ?? .preferredFontDescriptor(withTextStyle: .headline)
        
        appearance.largeTitleTextAttributes = [.font: UIFont(descriptor: largeDescriptor, size: 34)]
        appearance.titleTextAttributes = [.font: UIFont(descriptor: inlineDescriptor, size: 17)]
        
        // Aplica a configuração
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Background()
                
                ScrollView {
                    ForEach(viewModel.habits, id: \.self) { habit in
                        NavigationLink {
                            HabitPage(habit: habit)
                        } label: {
                            ZStack {
                                CalendarBackground()
                                
                                VStack {
                                    HStack {
                                        Text("\(habit.title ?? "")")
                                            .font(.system(size: 25, weight: .bold))
                                            .lineLimit(1)
                                            .fontDesign(.rounded)
                                            .foregroundStyle(.text)
                                        Spacer()
                                    }
                                    .padding()
                                    
                                    MonthName(month: dateNow.formatted(.dateTime.month(.wide)).capitalized)
                                        .foregroundStyle(.text)
                                    
                                    VStack(spacing: 1) {
                                        HStack(spacing: 19) {
                                            ForEach(dayInitials, id: \.self) { initial in
                                                Text(initial)
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(.text)
                                            }
                                        }
                                        .fontDesign(.rounded)
                                        .padding(.top)
                                        
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
                                    .padding(.bottom, 25)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Progress")
        }
        .onAppear {
            viewModel.getHabits()
            viewModel.getDays()
            checkDayIsDone()
            days = dateNow.calendarDisplayDays
        }
    }
    
    // MARK: - Functions
    
    func checkDayIsDone() {
        for habit in viewModel.habits {
            for day in viewModel.days {
                if habit.title == day.habit {
                    if let date = day.date, Date.now.startOfDay == date.startOfDay {
                        let color = habit.habitCount > 0 ? "verde" : "cinza"
                        viewModel.updateDay(day: day, dailyCount: habit.habitCount, date: date, color: color)
                    }
                }
            }
        }
    }
    
    func getAverage() -> Int16 {
        var average: Int16 = 0
        for habit in viewModel.habits {
            let doneDays = viewModel.days.filter { $0.habit == habit.title && $0.color == "verde" }
            if !doneDays.isEmpty {
                average = habit.totalCount / Int16(doneDays.count)
            } else {
                average = habit.totalCount
            }
        }
        return average
    }
}

#Preview {
    ProgressPage()
}
