//
//  File.swift
//  Inheal
//
//  Created by Thais Cangucu on 21/01/26.
//

import SwiftUI

struct FactsCard: View{
    var fact: Fact
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(.white)
                .opacity(0.7)
            ScrollView(.vertical){
                VStack(alignment: .leading, spacing: 21){
                    Text(fact.title)
                        .font(.title3)
                        .bold()
                    Text(fact.content)
                    Text("Source: \(fact.source))")
                }
            }
            .padding(30)
        }
        .frame(minWidth: 300, maxWidth: 550, maxHeight: 300)
    }
}
