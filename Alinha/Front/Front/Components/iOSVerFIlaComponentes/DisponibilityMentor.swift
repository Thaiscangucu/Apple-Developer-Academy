//
//  DisponibilityMentor.swift
//  iOSFront
//
//  Created by anshu Li on 27/08/25.
//

import SwiftUI

/// Component for showing the card on the bottom of the queue, that shows the mentor disponibility and place.
/// - Parameter disponibility: Bool for selecting the Mentor/Adm aviability
/// - Parameter selectLocation: String for selecting the Mentor/Adm location
struct DisponibilityMentor: View {
    @State var disponibility: Bool = false
    @State var selectLocation: String = ""

    var location = ["local1", "local2", "local3"]

    var body: some View {
        VStack {
            Spacer()
            VStack {
                List {
                    Section {
                        Toggle("Disponibilidade", isOn: $disponibility)
                            .font(.title3)
                        
                        Picker("Local", selection: $selectLocation) {
                            ForEach(location, id: \.self) { i in
                                Text(i)
                            }
                        }
                        .font(.title3)
                    }
                    .listRowSeparator(.hidden)
                    .bold()
                    .listRowBackground(Color.gray)
                }
                .scrollContentBackground(.hidden)
            }
            .background(.gray)
            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 27, topTrailing: 27)))
            .frame(height: 165)
        }
    }
}

#Preview {
    DisponibilityMentor()
}
