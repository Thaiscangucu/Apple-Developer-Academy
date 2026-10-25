//
//  NotificationManagerModel.swift
//  LocalNotificationDemo
//
//  Created by Diego Saragoza Da Silva on 25/06/25.
//

import Foundation
import SwiftUI
import UserNotifications

/// A model that abstracts a manager to send and schedule notifications.
struct NotificationManagerModel {

    public static var shared: NotificationManagerModel = {
        let instance = NotificationManagerModel()
        return instance
    }()

    private init() {}

    private static var coreDataViewModel: CoreDataViewModel = CoreDataViewModel()

    // MARK: - Botão de notificações do app

    /// Chaves do UserDefaults usadas pelo botão de notificações nos ajustes
    /// do app (`AddUserViewModel.notificationsOn`).
    private static let notificationsOnKey = "notificationsOn"
    private static let notificationsOnSetKey = "notificationsOnSet"

    /// Prefixo dos identificadores dos lembretes diários.
    private static let reminderIdentifierPrefix = "bill_reminder_"

    /// `true` quando o app pode agendar lembretes: o botão de notificações
    /// está ligado nos ajustes do app, ou o app ainda está na primeira
    /// abertura (o botão ainda não foi configurado e começa ligado).
    public static var isEnabledInApp: Bool {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: notificationsOnSetKey) else { return true }
        return defaults.bool(forKey: notificationsOnKey)
    }
    // MARK: - Solicitar Permissão e Agendar
    public static func requirePermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { status, error in
            if let error = error {
                print("[ERROR]: Falha ao solicitar permissão de notificações: \(error.localizedDescription)")
                return
            }

            if status {
                DispatchQueue.main.async {
                    scheduleWeeklyRandomNotifications()
                }
            } else {
                print("[WARNING]: Permissão de notificação negada pelo usuário.")
            }
        }
    }

    // MARK: - Mensagens dos lembretes

    /// Textos sorteados para os lembretes. Para adicionar uma mensagem,
    /// é só incluir aqui (e traduzir no Localizable.xcstrings).
    private static var reminderMessages: [NotificationModel] {
        [
            NotificationModel(
                title: String(localized: "Hora de rachar!"),
                body: String(localized: "A conta não vai se dividir sozinha, hein? 🤨")
            ),
            NotificationModel(
                title: String(localized: "Saiu com a galera?"),
                body: String(localized: "Escaneia a notinha e cada um paga só o que consumiu 🧾")
            ),
            NotificationModel(
                title: String(localized: "Quem pediu a porção?"),
                body: String(localized: "Deixa que a gente lembra quem comeu o quê 🍟")
            ),
            NotificationModel(
                title: String(localized: "Chega de calculadora na mesa"),
                body: String(localized: "Divide a conta em segundos e volta pro papo 💬")
            ),
            NotificationModel(
                title: String(localized: "Ninguém merece pagar a mais"),
                body: String(localized: "Cada um paga o seu, certinho, até os centavos 🪙")
            ),
            NotificationModel(
                title: String(localized: "Happy hour hoje?"),
                body: String(localized: "Quando a conta chegar, você já sabe o que fazer 🍻")
            ),
            NotificationModel(
                title: String(localized: "Taxa de serviço inclusa"),
                body: String(localized: "A gente divide a taxa de serviço certinho entre todo mundo ✨")
            ),
            NotificationModel(
                title: String(localized: "Aquele amigo que \"paga depois\"…"),
                body: String(localized: "Fecha a conta na hora e acaba com o fiado 😅")
            ),
            NotificationModel(
                title: String(localized: "Jantar em grupo?"),
                body: String(localized: "Uma foto da notinha e pronto: cada um sabe quanto deve 📸")
            ),
            NotificationModel(
                title: String(localized: "Matemática? Deixa com a gente"),
                body: String(localized: "Você aproveita, a gente faz as contas 🧮")
            )
        ]
    }

    // MARK: - Agenda dos lembretes (um por dia, texto variado)

    /// Quantos dias à frente ficam agendados. O iOS aceita no máximo 64
    /// notificações pendentes por app.
    private static let daysScheduledAhead = 28

    /// Quantos dias seguidos uma mesma mensagem não pode se repetir.
    private static let messageCooldownDays = 4

    /// Chave no `userInfo` com o índice da mensagem usada no lembrete.
    private static let messageIndexKey = "reminderMessageIndex"

    /// Identificadores antigos (lembretes semanais que se repetiam com o
    /// mesmo texto). São removidos para dar lugar à agenda nova.
    private static let legacyReminderIdentifierPrefix = "daily_bill_reminder_weekday_"

    /// Identificador de cada lembrete: prefixo + data ("bill_reminder_2026-10-22").
    private static func reminderIdentifier(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%@%04d-%02d-%02d",
            reminderIdentifierPrefix,
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    /// Mantém agendado um lembrete por dia nos próximos `daysScheduledAhead`
    /// dias, cada um num horário sorteado entre 10h e 20h e com uma mensagem
    /// sorteada (sem repetir a mesma em dias próximos).
    ///
    /// É chamado a cada abertura do app: os dias que já têm lembrete ficam
    /// como estão e só os que faltam no fim da agenda são completados.
    /// Assim os textos variam de semana para semana. Se a pessoa passar
    /// mais de `daysScheduledAhead` dias sem abrir o app, os lembretes acabam
    /// e voltam quando ela abrir de novo.
    public static func scheduleWeeklyRandomNotifications() {
        // Botão desligado nos ajustes do app: não agenda nada, mesmo que a
        // permissão do iOS continue concedida.
        guard isEnabledInApp else {
            print("[INFO]: Notificações desligadas no app — nada agendado.")
            return
        }

        let center = UNUserNotificationCenter.current()

        center.getPendingNotificationRequests { requests in
            // Remove os lembretes semanais antigos (texto sempre igual).
            let legacyIDs = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(legacyReminderIdentifierPrefix) }
            if !legacyIDs.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: legacyIDs)
            }

            // Lembretes que já estão agendados: identificador → mensagem usada.
            var scheduled: [String: Int] = [:]
            for request in requests where request.identifier.hasPrefix(reminderIdentifierPrefix) {
                scheduled[request.identifier] =
                    request.content.userInfo[messageIndexKey] as? Int ?? -1
            }

            DispatchQueue.main.async {
                // Confere de novo: o botão pode ter sido desligado nesse meio-tempo.
                guard isEnabledInApp else { return }
                fillReminderSchedule(alreadyScheduled: scheduled)
            }
        }
    }

    /// Agenda os dias que ainda não têm lembrete. Começa amanhã.
    private static func fillReminderSchedule(alreadyScheduled: [String: Int]) {
        let messages = reminderMessages
        guard !messages.isEmpty else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Mensagens dos últimos dias, para não repetir em sequência.
        var recentMessages: [Int] = []
        var addedCount = 0

        for offset in 1...daysScheduledAhead {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let identifier = reminderIdentifier(for: day)

            let messageIndex: Int
            if let existing = alreadyScheduled[identifier] {
                messageIndex = existing
            } else {
                let available = messages.indices.filter { !recentMessages.contains($0) }
                messageIndex = (available.isEmpty ? Array(messages.indices) : available).randomElement()!

                // Sortear hora entre 10:00 (600 min) e 20:00 (1200 min)
                let randomTotalMinutes = Int.random(in: (10 * 60)...(20 * 60))

                scheduleNotification(
                    notification: messages[messageIndex],
                    messageIndex: messageIndex,
                    day: day,
                    hour: randomTotalMinutes / 60,
                    minute: randomTotalMinutes % 60,
                    identifier: identifier
                )
                addedCount += 1
            }

            recentMessages.append(messageIndex)
            if recentMessages.count > min(messageCooldownDays, messages.count - 1) {
                recentMessages.removeFirst()
            }
        }

        print("[INFO]: \(addedCount) lembrete(s) novo(s) agendado(s).")

        // Atualiza a lista no CoreData ViewModel
        coreDataViewModel.getNotifications()
    }

    // MARK: - Agendamento Individual no iOS
    /// Agenda um lembrete único (sem repetição) para o dia e horário dados.
    private static func scheduleNotification(
        notification: NotificationModel,
        messageIndex: Int,
        day: Date,
        hour: Int,
        minute: Int,
        identifier: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        content.userInfo = [messageIndexKey: messageIndex]

        // ⚠️ FUSO HORÁRIO E CALENDÁRIO LOCAL (Evita agendamento de madrugada)
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: day)
        dateComponents.calendar = Calendar.current
        dateComponents.timeZone = TimeZone.current
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[ERROR]: Erro ao adicionar notificação no sistema: \(error.localizedDescription)")
            } else {
                print("[SUCCESS]: Lembrete \(identifier) às \(hour):\(String(format: "%02d", minute)) — \(notification.title)")
            }
        }
    }

    // MARK: - Status da Permissão
    /// Retorna true se o usuário autorizou notificações nos Ajustes do iOS.
    /// Status atual da permissão (nunca perguntado, negado, autorizado...).
    public static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    public static func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    // MARK: - Ligar Notificações
    /// Pede permissão (se necessário) e agenda. Retorna true se a permissão foi concedida.
    @MainActor
    public static func enableNotifications() async -> Bool {
        let granted = (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        if granted {
            scheduleWeeklyRandomNotifications()
        }
        return granted
    }

    // MARK: - Desligar Notificações
    /// Remove todas as notificações agendadas (usado quando o toggle vai para Off).
    public static func disableNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        // Também tira da Central de Notificações as que já tinham chegado.
        center.removeAllDeliveredNotifications()
    }

    // MARK: - Cancelar Notificação
    public static func cancelScheduledNotification(scheduledNotification: ScheduledNotification) {
        if let uuidString = scheduledNotification.id?.uuidString {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuidString])
        }
    }
}

