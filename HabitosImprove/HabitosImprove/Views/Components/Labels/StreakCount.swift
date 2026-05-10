//
//  Streak.swift
//  HabitosImprove
//
//  Created by Thais Canguçu on 15/08/25.
//

import SwiftUI

struct StreakCount: View {
    
    @ObservedObject var viewModel: CoreDataViewModel
    
    var body: some View {
        
        //Streak count + symbol
        ZStack{
            LabelRect(redWidth: 90)
                .shadow(color: .sombra, radius: 2, x: 0, y: 4)
            ForEach(viewModel.streaks, id: \.number) { streak in
                HStack{
                    Image(systemName:"flame.fill")
                        .foregroundStyle(.streakOrange)
                    Text("\(streak.number)")
                        .foregroundStyle(.text)
                        .font(.title)
                        .bold()
                }
            }
        }
        .onAppear{
            viewModel.getStreaks()
        }
    }
}
