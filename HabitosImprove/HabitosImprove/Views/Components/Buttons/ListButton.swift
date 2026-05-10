//
//  EditButton.swift
//  HabitosImprove
//
//  Created by Thais Canguçu on 14/07/25.
//

import SwiftUI

struct ListButton: View {
    var body: some View {
        NavigationLink{
            AllHabits() 
        } label: {
            Image(systemName: "list.bullet")
                .font(.title)
        }
    }
}

#Preview {
    ListButton()
}
