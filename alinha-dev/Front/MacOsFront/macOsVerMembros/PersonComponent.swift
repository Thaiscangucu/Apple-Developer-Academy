//
//  PersonComponent.swift
//  iOSFront
//
//  Created by anshu Li on 28/08/25.
//

import SwiftUI

///This struct has the visual about member, with this image(now a generic circle) and name.
///  - Parameter member: It's the variable that gets the member's properties.
struct PersonComponent: View {
    var member: DragableUser
    var isPressed: Bool
    var isDefault: Bool
    var ImageCard: String = ""
    
    var body: some View {
        
        if isDefault == false {
            VStack{
                ZStack{
                    Circle()
                        .frame(width: 80)
                        .foregroundStyle(.darkGreen)

                    Image(systemName: "person.fill")
                        .font(.system(size: 55))
                        .foregroundStyle(.white)
                }
                Text(member.name)
                    .font(.title3)
                    .bold()
            }
            .frame(width: 115, height: 115)
            
            .padding()
        }
        else {
            VStack{
                RoundedRectangle(cornerRadius: 24)
                    .frame(width: 147, height: 147)
                    .foregroundStyle(.white)
            }
        }
    }
    
}

//#Preview {
//    PersonComponent(member: DragableUser(from: ), isPressed: false, isDefault: false)
//}
