//
//  SoundsProduce.swift
//  Challenge8
//
//  Created by Binho Gadelha on 09/10/25.
//

import Foundation

import SwiftUI
import AVKit

 @Observable class SoundManager {
    
    init(player: AVAudioPlayer? = nil) {
        self.player = player
    }
    //singleton para nao ter que inicializar soundManager em cada View
    static let instance = SoundManager()
    
    //Variavel para tocar audio
    //TODO: Passar um player para cada objeto criado no SpriteKit
    var player: AVAudioPlayer?
     
     var player1: AVAudioPlayer?
     var player2: AVAudioPlayer?
     var player3: AVAudioPlayer?
    
    //Enum para tocar diferentes audios com a mesma funcao playSound()
    enum SoundOption: String {
        case tada
        case badum
        case tesouraAudio
        case Scissor
        case Shaver
        case BlowDryer
        case GarbageAudio
        case Shower
        case popAudio
        case Plastic
        case Speaker
        case none
    }
    
     func playSound(sound: SoundOption, soundName: String = "") {

         if soundName != ""{
             guard let url = Bundle.main.url(forResource: soundName, withExtension: ".mp3") else {return}
             
             do {
                 
                 player = try AVAudioPlayer(contentsOf: url)
                 player?.play()
             } catch let error {
                 print("Error playing sound\(error.localizedDescription)")
             }
             return
          }
         
        //variavel para guardar audio
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else {return}
        
        //TODO: passar um while True para tocar o audio infinitamente com bool para dar toogle caso o usuario queira parar de tocar o audio
        do {
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("Error playing sound\(error.localizedDescription)")
        }
    }
     
     func playTesoura(sound: SoundOption) {
             guard let path = Bundle.main.path(forResource: sound.rawValue, ofType: ".mp3") else {
                 print("Error: Audio file not found.")
                 return
             }
             let url = URL(fileURLWithPath: path)

             do {
                 player1 = try AVAudioPlayer(contentsOf: url)
                 player1?.numberOfLoops = -1 // Loop indefinitely
                 player1?.play()
             } catch {
                 print("Error playing audio: \(error.localizedDescription)")
             }
         }
     
     func playShaver(sound: SoundOption) {
             guard let path = Bundle.main.path(forResource: sound.rawValue, ofType: ".mp3") else {
                 print("Error: Audio file not found.")
                 return
             }
             let url = URL(fileURLWithPath: path)

             do {
                 player2 = try AVAudioPlayer(contentsOf: url)
                 player2?.numberOfLoops = -1 // Loop indefinitely
                 player2?.play()
             } catch {
                 print("Error playing audio: \(error.localizedDescription)")
             }
         }
     
     func playDryer(sound: SoundOption) {
             guard let path = Bundle.main.path(forResource: sound.rawValue, ofType: ".mp3") else {
                 print("Error: Audio file not found.")
                 return
             }
             let url = URL(fileURLWithPath: path)

             do {
                 player3 = try AVAudioPlayer(contentsOf: url)
                 player3?.numberOfLoops = -1 // Loop indefinitely
                 player3?.play()
             } catch {
                 print("Error playing audio: \(error.localizedDescription)")
             }
         }
     
     
     func stopTesoura() {
         player1?.stop()
         player1 = nil
     }
     
     func stopShaver() {
         player2?.stop()
         player2 = nil
     }
     
     func stopDryer() {
         player3?.stop()
         player3 = nil
     }

}

//Funcao para verificar se há 3 strings repetidas no vetor do cenario e gerar um feedback
