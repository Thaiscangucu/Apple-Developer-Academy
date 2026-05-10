//
//  SwiftUIView.swift
//  HabitosImprove
//
//  Created by Thais Canguçu on 27/07/25.
//

import SwiftUI

struct Pixel: View {
    
    var day: Int
    var color: String
    var today = Date.now
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 25, height:25)
                .foregroundStyle((today.dayInt == day) ? .accent : Color(color))
                
            Text("\(day)")
                .font(.footnote)
                .foregroundStyle((today.dayInt == day) ? .text : .black)
                .fontWeight((today.dayInt == day) ? .semibold : .regular)
                .fontDesign(.rounded)
        }
        
        
    }
}
