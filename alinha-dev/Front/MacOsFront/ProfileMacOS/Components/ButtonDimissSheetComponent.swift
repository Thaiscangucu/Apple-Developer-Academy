//
//  ButtonDimissSheetComponent.swift
//  macOSFront
//
//  Created by Isabela Hissa Pinto on 01/09/25.
//

import SwiftUI

///Button that emulates the closing role of a view, but is passed in a sheet.
struct ButtonDimissSheetComponent: View {
    var body: some View {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
                .padding()
    }
}

#Preview {
    ButtonDimissSheetComponent()
        .frame(width: 360, height: 336)
}
