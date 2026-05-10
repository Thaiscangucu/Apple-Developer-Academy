//
//  MemoriasView.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//

import SwiftUI

struct MemoriasView: View {
    var viewModel: CoreDataViewModel
    var body: some View {
        NavigationStack{
            ZStack{
                // Background image
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                NavigationLink{
                    PageView(viewModel: viewModel)
                }
                label:{
                    Image("Book")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 365, height: 516)
                }
            }
        }
    }
}

//#Preview {
//    MemoriasView()
//}
