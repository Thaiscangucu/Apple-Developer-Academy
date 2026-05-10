//
//  HabitStat.swift
//  HabitosImprove
//
//  Created by Thais Canguçu on 27/07/25.
//

import SwiftUI

struct HabitStat: View {
    
    let statTitle: LocalizedStringKey
    let count: Int16
    let unit: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: 4) {
            Text(statTitle)
            
            Text("\(count)")
            
            Text(unit)
        }
    }
}

// MARK: - Preview
#Preview {
    HabitStat(statTitle: "Total:", count: 10, unit: "times")
}
