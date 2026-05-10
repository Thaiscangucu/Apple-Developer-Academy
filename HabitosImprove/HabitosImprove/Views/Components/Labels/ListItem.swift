//
//  SwiftUIView.swift
//  HabitosImprove
//
//  Created by Thais Canguçu on 27/07/25.
//

import SwiftUI

struct ListItem: View {
    
    var title: String
    
    var body: some View {
        HStack{
            Text("\(title)")
            Spacer()
            Text("Details")
                .foregroundStyle(.detail)
        }
    }
}

#Preview {
    ListItem(title: "Read📚")
}
