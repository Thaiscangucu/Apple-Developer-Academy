//
//  ContentView.swift
//  POC_hapticEffects
//
//  Created by Isabela Hissa Pinto on 09/10/25.
//

import SwiftUI
import CoreHaptics

@Observable public class Haptics {
    private var engine: CHHapticEngine?
    
    init () {
        self.engine = nil
        self.prepateHaptics()
    }
    
    func prepateHaptics() { //Create the engine to run the haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Erro!! - \(error.localizedDescription)")
        }
    }
    
    func unlockedObject() {
        //Creates the haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        //Increasing pontual (.hapticTransient) vibration (array)
        for i in stride(from:0, to:1, by:0.2){
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        
        //Decay continuous (.hapticContinuous) vibration (sole)
        let boom = CHHapticEvent(
            eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1),
                CHHapticEventParameter(parameterID: .decayTime, value: 1)
            ], relativeTime: 0.9, duration: 0.2)
        events.append(boom)
        
        
        do { //Play the array of events
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Deu ruim - \(error.localizedDescription)")
        }
    }
    
    func droppedObjetc(){
        //Creates the haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        //Decay continuous (.hapticContinuous) vibration (sole)
        let boom = CHHapticEvent(
            eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1),
                CHHapticEventParameter(parameterID: .decayTime, value: 1)
            ], relativeTime: 0, duration: 0.2)
        events.append(boom)
        
        
        do { //Play the array of events
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Deu ruim - \(error.localizedDescription)")
        }
    }
}
