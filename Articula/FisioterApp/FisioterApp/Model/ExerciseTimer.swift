//
//  Timer.swift
//  FisioterApp
//
//  Created by Thais Cangucu on 06/04/26.
//
import UIKit
import Foundation

class ExerciseTimer {
    
    var timer: Timer?
    var segundos = 0
    var minutos = 0
    
    deinit {
        timer?.invalidate()
    }
    
    func startTimer() {
        segundos = 0
        minutos = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0,target: self,selector: #selector(updateTime),userInfo: nil,repeats: true)
    }
    
    @objc func updateTime() {
        segundos += 1
        if segundos == 60{
            minutos += 1
            segundos = 0
        }
        if segundos < 10{
            print("Tempo: \(minutos):0\(segundos)")
        }
        else{
            print("Tempo: \(minutos):\(segundos)")
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
