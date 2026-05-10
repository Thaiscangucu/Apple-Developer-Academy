//
//  BatuqueApp.swift
//  Batuque
//
//  Created by Pedro Augusto on 08/12/25.
//

import SwiftUI

@main
struct BatuqueApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
    }
}
