//
//  SmallRectangle.swift
//  tvOSFront
//
//  Created by Thais Cangucu on 29/08/25.
//

import SwiftUI
///SwiftUI View of the LastStudentCard view.
///
/// Shows where the student will be helped and which mentor will help.
struct SmallRectangle: View {
    
    var title: String
    var content: String
    
    var smallRecWidtht: CGFloat = 250
    var smallRecHeight: CGFloat = 108
    
    var white: Color = .white
    var blue: Color = .darkBlueText
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 28)
                .frame(width: smallRecWidtht, height: smallRecHeight)
                .foregroundStyle(white)
                .shadow(radius: 6, x: 0, y: 4)
            // Title + content
            VStack(spacing: 1){
                Text(title)
                    .foregroundColor(blue)
                    .font(.system(size: 28, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: smallRecWidtht, alignment: .leading)
                    .lineLimit(1)
                Text(content)
                    .foregroundColor(.black)
                    .font(.system(size: 34, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: smallRecWidtht, alignment: .leading)
                    .lineLimit(1)
            }
            .padding(.leading, 30)
            
        }
    }
}

#Preview {
    SmallRectangle(title: "Boardroom", content: "Joaquim")
}
