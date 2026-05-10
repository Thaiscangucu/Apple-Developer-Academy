//
//  MemoriasView.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//

//TODO: FINISH THIS VIEW
import SwiftUI

struct GuardianView: View {
    //    @Binding var name: String
    @AppStorage("kidName") var kidName: String = ""
    @State var goodJob = true
    var viewModel: CoreDataViewModel

    var body: some View {
        NavigationStack{
            ZStack{
                Image("GuardianViewBG")
                    .resizable()
                    .scaledToFill()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink{
                                RewardsView(viewModel: viewModel)
                            }label:{
                                Image("Trophy")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 42, height: 42)
                            }
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                
                VStack{
                    ZStack{
                        // Text Baloon
                        Image("TextBaloon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 323, height: 156)
                        
                        // Message
                        VStack{
                            Text(goodJob ? "Parabéns \(kidName)!" : "Cadê as tarefas?")
                                .font(.custom("Qilka", size: 20))
                                .foregroundColor(.text2)
                                .padding(.bottom, 5)
                            Text(goodJob ? "Me contaram que você fez todas as suas atividades de hoje, sua casa está linda!" : "\(kidName) não fez nenhuma atividade até agora. Vamos vencer esse desafio?")
                                .font(.custom("SF Compact Rounded", size: 14))
                                .foregroundColor(.text2)
                        }
                        .multilineTextAlignment(.center)
                        .frame(width: 280, height: 80)
                        .padding(.bottom, 40)
                        
                    }
                    // Guardian
                    Image(goodJob ? "Guardian" : "Guardian")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 394, height: 369)
                }
                .padding(.bottom, 20)

            }
            .ignoresSafeArea()
        }
    }
}
//
//#Preview {
//    GuardianView()
//}
