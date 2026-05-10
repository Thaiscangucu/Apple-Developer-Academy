//
//  StreakPage.swift
//  HabitosImprove
//
//  Created by Thais Canguçu on 27/07/25.
//

import SwiftUI

struct StreakPage: View {

    @ObservedObject var viewModel: CoreDataViewModel
    
    var body: some View {
        ZStack {
            Background()
            
            ForEach(viewModel.streaks, id: \.self) { streak in
                ZStack {
                    Circle()
                        .foregroundStyle(.orange)
                        .shadow(color: .sombra, radius: 2, x: 0, y: 4)
                    
                    VStack {
                        HStack {
                            Text("\(streak.number)")
                                .font(.system(size: 80, weight: .bold, design: .rounded))
                            
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: 60))
                        }
                        
                        Text("streak days!")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                }
                .padding()
            }
        }
        .navigationTitle("Streak")
        .onAppear {
            refreshData()
        }
    }
    
    // MARK: - Functions
    
    /// Carrega os dados de streaks do banco de dados
    func refreshData() {
        viewModel.getStreaks()
    }
}

// MARK: - Preview
#Preview {
    // Nota: Requer uma instância de CoreDataViewModel
    StreakPage(viewModel: CoreDataViewModel())
}
