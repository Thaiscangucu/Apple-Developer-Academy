//
//  SheetItem.swift
//  EventsApp
//
//  Created by Yasmin Mendes  on 08/09/26.
//

import Foundation

struct SheetItem: Identifiable {
    let id = UUID()

    let quantity: String
    let name: String
    let fraction: String
    let originalPrice: String
    let finalPrice: String
}
