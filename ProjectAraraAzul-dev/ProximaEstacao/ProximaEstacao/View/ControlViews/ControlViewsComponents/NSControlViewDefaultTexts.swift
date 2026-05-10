//
//  FruitsViewDefaultText.swift
//  ProximaEstacao
//
//  Created by Lucca Pivoto on 03/03/26.
//

import SwiftUI

struct NSControlViewDefaultText: View {
    let text: String
    let textSize: CGFloat
    var body: some View {
        Text(text)
            .fontWeight(.heavy)
            .font(.system(size: textSize))
            .fontDesign(.rounded)
    }
}
