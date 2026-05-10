//
//  TokenTextFielsComponent.swift
//  Front
//
//  Created by Isabela Hissa Pinto on 27/08/25.
//

import SwiftUI

struct TokenTextFieldComponent: View {
    @Binding var enterValue: [String]
    @FocusState private var fieldFocus: Int?
//    init() {
//        self.enterValue = Array(repeating: "", count: 6)
//    }
    
    var body: some View {
        HStack{
            ForEach(0..<6, id: \.self) { index in
                TextField("", text: $enterValue[index])
                    .keyboardType(.numberPad)
                    .frame(width: 40,height: 60)
                    .background(
                        Rectangle()
                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .frame(width: 40,height: 60)
                        
                            .shadow(color: .black.opacity(0.45), radius: 3,x: 0, y:2)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(8))
                
                    .multilineTextAlignment(.center)
                    .focused($fieldFocus, equals: index)
                    .tag(index)
                    .onChange(of: enterValue[index]) { newValue in
                        if index == 5 {
                            fieldFocus = nil
                        } else {
                            fieldFocus = (fieldFocus ?? 0) + 1
                        }
                    }
            }
        }
    }
}
