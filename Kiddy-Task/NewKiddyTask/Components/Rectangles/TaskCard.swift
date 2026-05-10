//
//  HomeTaskRectView.swift
//  NewKiddyTask
//
//  Created by Camila Parolin on 01/02/26.
//

import SwiftUI
import AVFoundation

struct TaskCard: View {
    var viewModel: CoreDataViewModel
    @ObservedObject var task: Tarefa
    @State var taskSheet = false
    @State var showingSheet = false
    
    let synthesizer = AVSpeechSynthesizer()
    
    var darkerColor: Color {
        switch task.color {
        case "blueTask":   return Color(red: 0.01, green: 0.71, blue: 0.85)
        case "pinkTask":   return Color(red: 1, green: 0.35, blue: 0.48)
        case "greenTask":  return Color(red: 0.45, green: 0.72, blue: 0.08)
        case "purpleTask": return Color(red: 0.69, green: 0.38, blue: 1)
        case "yellowTask": return Color(red: 1, green: 0.55, blue: 0.01)
        case "redTask":    return Color(red: 1, green: 0, blue: 0.2)
        default:           return .gray
        }
    }
    var body: some View {
        ZStack {
            // Backgorund
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color(task.color ?? "white"))
                .frame(width: 280, height: 388)
            
            VStack {
                // Nome + Botão
                HStack {
                    
                    Button {
                        speakText("\(task.title ?? "")")
                    } label: {
                        Text("\(task.title ?? "")")
                            .font(.custom("Qilka", size: 35))
                            .frame(width: 170, height: 120, alignment: .leading)
                            .foregroundStyle(.white)
                    }
                    
                   
                    
                    Button {
                        taskSheet.toggle()
                    }
                    label: {
                        ZStack {
                            Circle()
                                .foregroundColor(.clear)
                                .frame(width: 50, height: 50)
                                .cornerRadius(13)
                                .overlay(
                                    Circle()
                                        .inset(by: 0.75)
                                        .stroke(darkerColor ??  .white, lineWidth: 1.5)
                                )
                            Circle()
                                .frame(width: 43, height: 43)
                                .foregroundStyle(darkerColor ??  .white)
                                .cornerRadius(12)
                            if task.done{
                                Image("Star")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 43, height: 30)
                            }
                            
                        }
                    }
                }
                
                // Imagem Card
                Image(task.image ?? "")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 238, height: 116)
                    .cornerRadius(16)
                Spacer()
                    .frame(height: 60)
                
                // Símbolos
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 224, height: 59)
                        .foregroundStyle(darkerColor ?? .white)
                    HStack(spacing: 30) {
                            // Convertemos task.symbols para um array de String com segurança
                            let symbolsArray = task.symbols as? [String] ?? []
                            
                            ForEach(symbolsArray, id: \.self) { symbol in
                                Image(systemName: symbol)
                                    .font(.system(size: 33))
                                    .foregroundStyle(Color.white)
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $taskSheet) {
            TaskView(viewModel: viewModel, task: task, sheet: $taskSheet)
        }
    }
    
    func speakText(_ text: String) {
        //configura o que será dito
        let utterance = AVSpeechUtterance(string: text)
        
        //configura a voz para portugues
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
        
        //velocidade da leitura
        utterance.rate = 0.4
        
        //faz falar
        synthesizer.speak(utterance)
    }
    
}
