//
//  EventsAppApp.swift
//  EventsApp
//
//  Created by Thais Cangucu on 07/08/26.
//

import SwiftUI
import SwiftData

@main
struct EventsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: [SavedUser.self, SavedBill.self, SavedBillItem.self, SavedBillUser.self,])
    }
}
