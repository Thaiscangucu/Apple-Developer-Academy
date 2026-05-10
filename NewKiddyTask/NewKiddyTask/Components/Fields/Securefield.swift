//
//  Textfield.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//

import SwiftUI

struct Securefield: View {
    @Binding var input: String
    @State var isSecure: Bool = true
    
    var width: CGFloat = 270
    var height: CGFloat = 42
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 22)
                .frame(width: width, height: height)
                .foregroundStyle(Color(red: 0.92, green: 0.96, blue: 0.96))
            Group{
                if isSecure{
                    SecureField("", text: $input)
                    
                }else{
                    TextField("", text: $input)
                }
            }
            .foregroundStyle(.black)
            .animation(.easeInOut(duration: 0.2), value: isSecure)
            .frame(width: width - 35)
            HStack{
                Spacer()
                Button(action: {
                    isSecure.toggle()
                }, label: {
                    Image(systemName: !isSecure ? "eye.slash" : "eye" )
                        .foregroundColor(Color(red: 0.63, green: 0.8, blue: 0.83))
                })
            }
            .frame(width: width - 35)
        }
        .frame(width: width, height: height)
    }
}
