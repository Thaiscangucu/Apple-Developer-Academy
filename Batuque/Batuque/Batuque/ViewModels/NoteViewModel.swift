//
//  NoteViewModel.swift
//  Batuque
//
//  Created by Pedro Augusto on 08/12/25.
//

import Foundation
import Observation
import AVFoundation
import RealityKitContent
import RealityKit

@Observable
class NoteViewModel {
    var audioPlayer: AVAudioPlayer?
    
    var buttons: [Entity: Note] = [:]
    
    var folder: String = "Goofy"
    
    func playNote(_ filePath: String) {
        let url = URL(fileURLWithPath: filePath)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
