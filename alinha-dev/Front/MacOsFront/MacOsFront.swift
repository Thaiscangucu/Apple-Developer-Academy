//
//  MacOsFront.swift
//  MacOsFront
//
//  Created by Jonas Fernando Nascimento Melo on 20/08/25.
//

import AppIntents

struct MacOsFront: AppIntent {
    static var title: LocalizedStringResource { "MacOsFront" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
