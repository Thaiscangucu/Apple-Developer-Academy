//
//  ContentViewModel.swift
//  ToDoListEmpty
//
//  Created by Laura C. Balbachan dos Santos on 23/05/25.
//

import Foundation
import CoreData

@Observable
class CoreDataViewModel{
    
    static let shared = CoreDataViewModel()
    
    var sessions: [Session] = []
    var reports: [Report] = []
    
    func getSessions() {
        sessions = CoreDataController.shared.fetchAllToDos()
    }
    
    func createSesssion(autonomy: Bool, completed: Bool, date: Date, difficulty: Int16, duration: Int16, painRate: Int16, repetitions: Int16) {
        let session = CoreDataController.shared.createSesssion(autonomy, completed, date, difficulty, duration, painRate, repetitions)
        self.sessions.append(session)
    }
    
    func deleteToDo(_ session: Session) {
        CoreDataController.shared.deleteToDo(session)
    }
    
    func getReport() {
        reports = CoreDataController.shared.fetchAllReportTopics()
    }
    
    func createReport(autonomy: String, completed: String, difficulty: String, duration: String, painRate: Int16, dateCreate: Date, datePeriod1: Date, datePeriod2: Date) {
        let report = CoreDataController.shared.createReport(autonomy, completed, difficulty, duration, painRate, dateCreate, datePeriod1, datePeriod2)
        self.reports.append(report)
    }
    
    func updateHabit(autonomy: String, difficulty: String, painRate: Int16) {
        for report in reports {
            CoreDataController.shared.updateReport(report: report, autonomy: autonomy, difficulty:difficulty, painRate: painRate)
        }

    }
    
    func deleteTopics(_ report: Report) {
        CoreDataController.shared.deleteReportTopics(report)
    }
    
    
    
}
