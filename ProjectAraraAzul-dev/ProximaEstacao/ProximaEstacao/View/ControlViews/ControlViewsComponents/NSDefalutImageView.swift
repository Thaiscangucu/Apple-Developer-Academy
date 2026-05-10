//
//  Fruits.swift
//  ProximaEstacao
//
//  Created by Lucca Pivoto on 02/03/26.
//

import SwiftUI

struct NSDefalutImageView: View {
    let imageName: String
    let frameWidth: CGFloat
    let frameHeight: CGFloat
    var body: some View {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: frameWidth , height: frameHeight)
    }
}
