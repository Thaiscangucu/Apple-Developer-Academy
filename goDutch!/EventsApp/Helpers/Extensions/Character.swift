//
//  File.swift
//  EventsApp
//
//  Created by Thais Cangucu on 12/08/26.
//

extension Character {
    var isEmoji: Bool {
        for scalar in unicodeScalars {
            if scalar.properties.isEmoji {
                return true
            }
        }
        return false
    }
}
