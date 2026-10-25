//
//  ContentViewModel.swift
//  KiddyTask
//
//  Created by Camila Parolin on 15/07/25.
//

import Foundation
import CoreData
import PhotosUI

@Observable
class CoreDataViewModel {
    var tarefas: [Tarefa] = []
    var recompensas: [Recompensa] = []
    var scheduledNotifications: [ScheduledNotification] = []
    
    
    public func getNotifications() {
        scheduledNotifications = CoreDataModel.shared.fetchScheduledNotifications()
    }
    
    func getTarefas() {
        let result = CoreDataModel.shared.fetchTarefas()
        // Remove duplicados por ID apenas por segurança
        self.tarefas = result
    }
    
    func getRecompensas() {
        let result = CoreDataModel.shared.fetchRecompensas()
        // Isso garante que você não está apenas adicionando (append) itens ao array que já existe
        DispatchQueue.main.async {
            self.recompensas = result
        }
    }

    func createTarefa(title: String, desc: String, done: Bool, image: String, symbols: [String], color: String, date: Date, picAfter: UIImage) {
        // 1. Cria no Core Data
        _ = CoreDataModel.shared.createTarefa(title: title, desc: desc, done: done, image: image, symbols: symbols, color: color, date: date, picAfter: picAfter)
        
        // 2. Sincroniza a lista local com o banco
        getTarefas()
    }
    
    func createRecompensa(title: String, freq: Int16, symbol: String, color: String) {
        // 1. Cria no banco
        _ = CoreDataModel.shared.createRecompensa(title: title, freq: freq, symbol: symbol, color: color)
        
        // 2. Atualiza a lista local garantindo que o SwiftUI perceba a mudança de estado
        Task { @MainActor in
            let novosResultados = CoreDataModel.shared.fetchRecompensas()
            // Atribuir um novo array inteiro dispara a atualização da View
            self.recompensas = novosResultados
        }
    }
    
    // Task toggle function
    func taskToggle(_ task: Tarefa) {
        CoreDataModel.shared.toggleTarefa(task)
        // Salva a mudança no banco de dados imediatamente
        CoreDataModel.shared.saveContext()
    }
    
    public func createScheduledNotification(id: UUID, date: Date) {
        let newScheduledNotification: ScheduledNotification = CoreDataModel.shared.createScheduledNotification(id: id, date: date)
        self.scheduledNotifications.append(newScheduledNotification)
    }

    public func deleteScheduledNotification(scheduledNotification: ScheduledNotification) {
        CoreDataModel.shared.deleteNotification(scheduledNotification: scheduledNotification)
    }
}
