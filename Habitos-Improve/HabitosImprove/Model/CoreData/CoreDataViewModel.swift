//
//  CoreDataViewModel.swift
//  HabitosImprove
//
//  Created by Thais Cangucu on 16/07/25.
//
import Foundation
import CoreData
import SwiftUI

class CoreDataViewModel: ObservableObject {
    @Published public var habits: [Habit] = []
    @Published public var days: [Day] = []
    @Published public var streaks: [Streak] = []
    @Published public var scheduledNotifications: [ScheduledNotification] = []
    
    /// Fetches all habits from the data store and updates the local published property.
    public func getHabits() {
        habits = CoreDataModel.shared.fetchHabits()
    }
    
    /// Creates a new habit and appends it to the local habits list.
    public func createHabit(title: String, descricao: String, goalQuantity: Int16, goalUnit: String, reminders: Bool, reminderTime: Date) {
        let newHabit = CoreDataModel.shared.createHabit(title: title, descricao: descricao, goalQuantity: goalQuantity, goalUnit: goalUnit, reminders: reminders, reminderTime: reminderTime)
        habits.append(newHabit)
    }
    
    /// Deletes a specific habit from the data store.
    public func deleteHabit(habit: Habit) {
        CoreDataModel.shared.deleteHabit(habit: habit)
    }
    
    /// Updates an existing habit's details in the data store.
    public func updateHabit(habit: Habit, title: String, descricao: String, goalQuantity: Int16, goalUnit: String, reminders: Bool, reminderTime: Date, newCount: Int16, totalCount: Int16) {
        CoreDataModel.shared.updateHabit(habit: habit, title: title, descricao: descricao, goalQuantity: goalQuantity, goalUnit: goalUnit, reminders: reminders, reminderTime: reminderTime, newCount: newCount, totalCount: totalCount)
    }
    
    /// Resets the daily count for all habits currently in the list.
    public func zeroDailyCount() {
        habits.forEach { CoreDataModel.shared.zeroDailyCount(habit: $0) }
    }
    
    /// Fetches all recorded days from the data store.
    public func getDays() {
        days = CoreDataModel.shared.fetchDays()
    }
    
    /// Records a new day entry for a specific habit.
    public func createDay(habit: String, date: Date, color: String) {
        let newDay = CoreDataModel.shared.createDay(habit: habit, date: date, color: color)
        days.append(newDay)
    }
    
    /// Updates the data for a specific day entry.
    public func updateDay(day: Day, dailyCount: Int16, date: Date, color: String) {
        CoreDataModel.shared.updateDay(day: day, dailyCount: dailyCount, date: date, color: color)
    }
    
    /// Removes a specific day entry from the data store.
    public func deleteDay(day: Day) {
        CoreDataModel.shared.deleteDay(day: day)
    }
    
    /// Clears all day records associated with a specific habit name.
    public func clearDays(habit: String) {
        CoreDataModel.shared.clearDays(days: days, habit: habit)
    }
    
    /// Fetches all scheduled notification records from the data store.
    public func getNotifications() {
        scheduledNotifications = CoreDataModel.shared.fetchScheduledNotifications()
    }
    
    /// Stores a new scheduled notification record.
    public func createScheduledNotification(id: UUID, date: Date) {
        let newNotification = CoreDataModel.shared.createScheduledNotification(id: id, date: date)
        scheduledNotifications.append(newNotification)
    }
    
    /// Deletes a specific scheduled notification record.
    public func deleteScheduledNotification(scheduledNotification: ScheduledNotification) {
        CoreDataModel.shared.deleteNotification(scheduledNotification: scheduledNotification)
    }
    
    /// Fetches all streak data from the data store.
    public func getStreaks() {
        streaks = CoreDataModel.shared.fetchStreaks()
    }
    
    /// Initializes a new streak record.
    public func createStreak() {
        let newStreak = CoreDataModel.shared.createStreak()
        streaks.append(newStreak)
    }
    
    /// Increments the value of all active streaks.
    public func increaseStreak() {
        CoreDataModel.shared.increaseStreak(streaks: streaks)
    }
    
    /// Resets the value of all active streaks to zero.
    public func resetStreak() {
        CoreDataModel.shared.resetStreak(streaks: streaks)
    }

    /// Deletes a specific streak record.
    public func deleteStreak(streak: Streak) {
        CoreDataModel.shared.deleteStreak(streak: streak)
    }
    
    /// Checks if a day entry already exists for the given habit and date.
    /// - Returns: A boolean indicating if the record exists.
    public func dayExists(habit: String, date: Date) -> Bool {
        CoreDataModel.shared.dayExists(habit: habit, date: date)
    }
}
