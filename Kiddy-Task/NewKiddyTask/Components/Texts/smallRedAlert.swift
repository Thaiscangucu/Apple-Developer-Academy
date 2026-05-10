//
//  text.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 01/02/26.
//

import SwiftUI

struct smallRedAlert: View {
    var text: String
    var textFont: CGFloat
    var textWeight: Font.Weight

    var body: some View {
        Text(text)
            .fontDesign(.rounded)
            .foregroundColor(Color(red: 0.25, green: 0.47, blue: 0.51))
            .fontWeight(textWeight)
            .font(.system(size: textFont))
    }
}

