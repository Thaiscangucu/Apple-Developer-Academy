//
//  MacOSQueueMentorToolbar.swift
//  macOSFront
//
//  Created by anshu Li on 01/09/25.
//

import SwiftUI

///View for showing the mentor toolbar, where you can set the disponobolity and the place
///- Parameter disponibility: disponobility in call about mentor/adm
///- Parameter local: the local selected by mentor/adm
struct MacOSQueueMentorToolbar: View {
    @State var disponibility: Bool = false
    @State var local: Int = 0
    var body: some View {
        HStack{
            Text("Disponibilidade: ")
            
            Toggle("Disponibilidade: ", isOn: $disponibility)
                .toggleStyle(.switch)
            
            Picker("Local", selection: $local ){
                Text("Local1").tag(0)
                Text("Local2").tag(1)
                Text("Local3").tag(2)
            }
            .frame(width: 100)
        }
    }
}

#Preview {
    MacOSQueueMentorToolbar()
}
