//
//  ReewardsView.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 03/02/26.
//

import SwiftUI

struct RewardsView: View {
    @Environment(\.dismiss) var dismiss
    let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    @State var newRewardSheet = false
    var viewModel: CoreDataViewModel
    
    var body: some View {
        ZStack{
            Image("RewardsBG")
                .resizable()
                .scaledToFill()
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image("backButton")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                        }
                    }
                    .sharedBackgroundVisibility(.hidden)
                }
                .ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 1) {
                    Button(action: {
                        newRewardSheet.toggle()
                    }) {
                        Image("puzzlePlus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 170, height: 170)
                    }
                    ForEach(Array(viewModel.recompensas.enumerated()), id: \.element.objectID) { indice, item in
                        VStack {
                            if indice % 2 == 0 {
                                rightPiece(text: item.title ?? "", freq: Int(item.freq))
                            } else {
                                leftPiece(text: item.title ?? "", freq: Int(item.freq))
                            }
                            
                        }                    }
                    .id(viewModel.recompensas.count)
                }
            }
            .frame(height: 600)
        }
        .onAppear {
            viewModel.getRecompensas()
        }
        
        .sheet(isPresented: $newRewardSheet, onDismiss: {
            viewModel.getTarefas()
        }) {
            NewRewardForm(viewModel: viewModel, isShowingSheet: $newRewardSheet)
        }
    }
}

