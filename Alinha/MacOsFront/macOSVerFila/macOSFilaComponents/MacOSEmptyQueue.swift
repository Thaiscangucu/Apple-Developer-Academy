//
//  MacOSEmptyQueue.swift
//  macOSFront
//
//  Created by anshu Li on 01/09/25.
//

import SwiftUI
/// View for showing the image at the bottom of a empty queue
struct MacOSEmptyQueue: View {
    var body: some View {
        VStack {
            Text("Parece que não tem ")
                .font(.title)
                .foregroundStyle(.black)
            Text("ninguém aqui ainda...")
                .font(.title)
                .foregroundStyle(.black)
            Image("merfinoFila")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 230)
            Ellipse()
                .frame(width: 177, height: 12)
                .blur(radius: 10.6)
                .padding()
        }
    }
}

#Preview {
    MacOSEmptyQueue()
}
