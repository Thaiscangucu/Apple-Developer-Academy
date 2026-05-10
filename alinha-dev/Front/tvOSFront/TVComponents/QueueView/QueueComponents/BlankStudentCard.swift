//
//  StudentCard.swift
//  tvOSFront
//
//  Created by Thais Cangucu on 28/08/25.
//

import SwiftUI
///SwiftUI view in QueueView page, that contains the student's name and icon.
struct BlankStudentCard: View {
    
    var RecWidth: CGFloat = 220
    var RecHeight: CGFloat = 80
    var CircleSize: CGFloat = 60
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .frame(width: RecWidth, height: RecHeight)
                .foregroundStyle(.studentCardBackground)
                .shadow(radius: 6, x: 0, y: 4)
            ZStack{
                HStack(alignment: .center, spacing: -16){
                    Circle()
//                        .foregroundStyle(.iconCircle)
                        .foregroundStyle(.studentCardBackground)
                        .frame(width: CircleSize, height: CircleSize)
                    Spacer()
                }
                .frame(width: 192)
            }
        }
    }
}

#Preview {
    BlankStudentCard()
}
