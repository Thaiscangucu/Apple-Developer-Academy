//
//  HabitFormView.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 18/12/25.
//

import SwiftUI

enum HabitFormMode: Equatable {
    case create
    case edit(Habit)
}

struct HabitFormView: View {
    @ObservedObject var viewModel: CoreDataViewModel
    @Environment(\.dismiss) var dismiss
    
    let mode: HabitFormMode
    let units = ["Pages", "Cups", "Fl oz", "Minutes", "Hours", "Miles", "Units"]
    
    
    @State private var titleAlert = false
    @State private var deleteAlert = false
    @State private var repeatedTitleAlert = false
    @State private var goalAlert = false
    
    @State private var title: String
    @State private var descricao: String
    @State private var goalQuantity: Int16
    @State private var goalUnit: String
    @State private var reminders: Bool
    @State private var reminderTime: Date
    
    @State private var days: [Date] = []
    @State private var dateNow = Date.now
    
    init(viewModel: CoreDataViewModel, mode: HabitFormMode) {
        self.viewModel = viewModel
        self.mode = mode
        
        switch mode {
        case .create:
            _title = State(initialValue: "")
            _descricao = State(initialValue: "")
            _goalQuantity = State(initialValue: 0)
            _goalUnit = State(initialValue: "Pages")
            _reminders = State(initialValue: false)
            _reminderTime = State(initialValue: .now)
            
        case .edit(let habit):
            _title = State(initialValue: habit.title ?? "")
            _descricao = State(initialValue: habit.descricao ?? "")
            _goalQuantity = State(initialValue: habit.goalQuantity)
            _goalUnit = State(initialValue: habit.goalUnit ?? "Pages")
            _reminders = State(initialValue: habit.reminders)
            _reminderTime = State(initialValue: habit.reminderTime ?? .now)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Background()
                
                Form {
                    infoSection
                    goalSection
                    remindersSection
                }
                .navigationTitle(mode == .create ? "New Habit" : "Edit Habit")
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
                .opacity(0.85)
                .toolbar { toolbarContent }
                .alert("New habit needs a title", isPresented: $titleAlert) {
                    Button("OK") {}
                }
                .alert("New habit needs a goal", isPresented: $goalAlert) {
                    Button("OK") {}
                }
                .alert("You've already created a habit with that title", isPresented: $repeatedTitleAlert) {
                    Button("OK") {}
                }
                .alert("Are you sure you wish to delete habit?", isPresented: $deleteAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        handleDelete()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupForm()
        }
    }
}

// MARK: - Subviews

private extension HabitFormView {
    var infoSection: some View {
        Section("Info") {
            TextField("Title", text: $title)
            TextField("Description (optional)", text: $descricao)
        }
    }
    
    var goalSection: some View {
        Section("Goal") {
            HStack {
                TextField("", value: $goalQuantity, format: .number)
                    .keyboardType(.numberPad)
                
                Picker("", selection: $goalUnit) {
                    ForEach(units, id: \.self) { Text($0) }
                }
                Text("per Day")
            }
        }
    }
    
    var remindersSection: some View {
        Section("Reminders") {
            Toggle("Daily Reminders", isOn: $reminders)
                .onChange(of: reminders) { newValue in
                    if newValue {
                        NotificationManagerModel.requirePermissions()
                    }
                }
            
            if reminders {
                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                
            }
        }
    }
    
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveHabit() }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            
            if case .edit = mode {
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        deleteAlert.toggle()
                    } label: {
                        Text("Delete Habit")
                    }
                }
            }
        }
    }
}

// MARK: - Functions

private extension HabitFormView {
    
    /// Initializes data and calendar days when the form appears.
    func setupForm() {
        viewModel.getHabits()
        viewModel.getDays()
        days = dateNow.calendarDisplayDays
    }
    
    /// Validates inputs and either creates or updates a habit in Core Data.
    func saveHabit() {
        if title.isEmpty {
            titleAlert.toggle()
            return
        }
        
        if goalQuantity <= 0 {
            goalAlert.toggle()
            return
        }
        
        // Only check for duplicates if it's a new habit
        if case .create = mode, isHabitDuplicate() {
            repeatedTitleAlert.toggle()
            return
        }
        
        createDays()
        
        switch mode {
        case .create:
            viewModel.createHabit(
                title: title,
                descricao: descricao,
                goalQuantity: goalQuantity,
                goalUnit: goalUnit,
                reminders: reminders,
                reminderTime: reminderTime
            )
            
        case .edit(let habit):
            viewModel.updateHabit(
                habit: habit,
                title: title,
                descricao: descricao,
                goalQuantity: goalQuantity,
                goalUnit: goalUnit,
                reminders: reminders,
                reminderTime: reminderTime,
                newCount: habit.habitCount,
                totalCount: habit.totalCount
            )
        }
        if reminders {
            let notification = NotificationModel(
                title: "Time for your habit \(title)",
                subtitle: "",
                body: "Don't forget to complete your goal: \(goalQuantity) \(goalUnit)."
            )
            let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            
            NotificationManagerModel.scheduleNotification(notification: notification, hour: hour, minute: minute, repeating: true)
        }
        
        dismiss()
    }
    
    /// Logic to handle habit deletion from the edit alert.
    func handleDelete() {
        if case .edit(let habit) = mode {
            viewModel.deleteHabit(habit: habit)
            viewModel.getHabits()
            dismiss()
        }
    }
    
    /// Generates initial daily tracking entries for the calendar.
    func createDays() {
        for day in days {
            viewModel.createDay(habit: title, date: day, color: "cinza")
        }
    }
    
    /// Checks if a habit with the same title already exists.
    func isHabitDuplicate() -> Bool {
        viewModel.habits.contains { $0.title == title }
    }
}
