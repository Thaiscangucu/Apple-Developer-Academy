//
//  PlusButton.swift
//  HabitosImprove
//

import SwiftUI

/// Defines the visual style of the plus button.
enum PlusButtonType {
    case circle
    case regular
}

struct PlusButton: View {
    let type: PlusButtonType
    @ObservedObject var viewModel: CoreDataViewModel
    @State private var isShowing = false

    var body: some View {
        Button {
            isShowing.toggle()
        } label: {
            buttonLabel
        }
        .sheet(isPresented: $isShowing, onDismiss: {
            viewModel.getHabits()
        }) {
            HabitFormView(
                viewModel: viewModel,
                mode: .create
            )
            .presentationDetents([.large])
        }
    }

    /// Generates the appropriate label view based on the button type.
    @ViewBuilder
    private var buttonLabel: some View {
        switch type {
        case .circle:
            ZStack {
                Circle()
                    .foregroundStyle(.darkerGreen)
                    .frame(width: 320, height: 300)
                    .opacity(0.7)
                    .shadow(color: .sombra, radius: 2, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.largeTitle)
            }
        case .regular:
            Image(systemName: "plus")
                .font(.title)
        }
    }
}
