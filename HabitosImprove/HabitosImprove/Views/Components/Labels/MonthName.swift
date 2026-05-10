//
//  MonthTitle.swift
//  HabitosImprove
//
//  Created by Thais Canguçu on 27/07/25.
//

import SwiftUI

struct MonthName: View {
    
    var month: String
    
    var body: some View {
        Text("\(month)")
            .font(.title2)
            .bold()
            .fontDesign(.rounded)
            .padding(.trailing, 250)
    }
}

//#Preview {
//    MonthTitle()
//}
