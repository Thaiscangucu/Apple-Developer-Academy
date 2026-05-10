//
//  ContentView.swift
//  POC-animação
//
//  Created by Thais Cangucu on 08/01/26.
//

import SwiftUI
internal import Combine

struct BreatheView: View {
    
    @State var breathing = false
    @State var isInhaling = false
    @State var isHolding = false
    @State var isExhaling = false
    
    @State var grow = false
    @State var standingBy = true
    @State var waiting = true
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timer2 = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    @State var inhaleCount = 0
    @State var holdCount = 0
    @State var exhaleCount = 0
    @State var breathsCount = 0
    
    var breathingDuration: Double = 6.0
    
    var body: some View {
        ZStack{
            Background()
            
            // Instruction Prompt
            VStack{
                if isInhaling {
                    Text("Breath in")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(isInhaling ? 1.0 : 0.0)
                }
                if isHolding {
                    Text("Hold")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(isHolding ? 1.0 : 0.0)
                }
                if isExhaling {
                    Text("Breath out")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(isExhaling ? 1.0 : 0.0)
                }
                VStack(spacing: 130){
                    Text(breathing ? "" : "Take a minute to breathe.")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    
                    // Circle with counter
                    ZStack{
                        Circle()
                            .frame(width: 300, height: 300)
                            .scaleEffect(grow ? 1.5 : 1.0)
                            .scaleEffect(waiting ? 1.0 : 1.1)
                            .foregroundStyle(.white)
                            .opacity(0.7)
                        
                        Circle()
                            .frame(width: 175, height: 180)
                            .foregroundStyle(.white)
                            .opacity(0.85)
                            .scaleEffect(grow ? 1.5 : 1.0)
                            .scaleEffect(waiting ? 1.0 : 1.1)
                        
                        //Counter
                        
//                        if isInhaling{
//                            if inhaleCount > 0 {
//                                Text("\(inhaleCount)")
//                                    .font(.system(size: 34, weight: .semibold, design: .rounded))
//                                    .foregroundStyle(.black)
//                            }
//                        }
//                        if isHolding{
//                            Text("\(holdCount)")
//                                .font(.system(size: 34, weight: .semibold, design: .rounded))
//                                .foregroundStyle(.black)
//                        }
//                        if isExhaling{
//                            Text("\(exhaleCount)")
//                                .font(.system(size: 34, weight: .semibold, design: .rounded))
//                                .foregroundStyle(.black)
//                        }
                    }
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.3)){
                            breathing = true
                            isInhaling = true
                            standingBy = false
                            breathsCount = 0
                        }
                    }
                    .padding(.vertical)
                    
                    // Stop Breathing Button
                    if breathing{
                        ZStack{
                            RoundedRectangle(cornerRadius: 32)
                                .frame(width: 370, height: 55)
                                .foregroundStyle(.white)
                                .opacity(0.6)
                            HStack{
                                Image(systemName: "stop.fill")
                                Text("Stop")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.linear(duration: 0.3)){
                                breathing = false
                                isInhaling = false
                                isHolding = false
                                isExhaling = false
                                grow = false
                                standingBy = true
                                waiting = true
                                inhaleCount = 0
                                holdCount = 0
                                exhaleCount = 0
                                breathsCount = 0
                            }
                        }
                    }
                    else{
                        // Breathe Button
                        ZStack{
                            RoundedRectangle(cornerRadius: 32)
                                .frame(width: 370, height: 55)
                                .foregroundStyle(.blue)
                                .opacity(breathing ? 0.0 : 1.0)
                            Text("Breath")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .opacity(breathing ? 0.0 : 1.0)
                        }
                        .onTapGesture {
                            withAnimation(.linear(duration: 0.3)){
                                breathing.toggle()
                                isInhaling.toggle()
                                standingBy = false
                                breathsCount = 0
                            }
                        }
                    }
                }
            }
        }
        
        .preferredColorScheme(.light)
        
        //Breathing Logic
        .onReceive(timer){_ in
            if breathing{
                if isInhaling {
                    withAnimation(.linear(duration: breathingDuration)){
                        grow = true
                    }
                    inhaleCount += 1
                    if inhaleCount > 6 {
                        inhaleCount = 0
                        isHolding = true
                        isInhaling = false
                    }
                    
                }
                if isHolding{
                    holdCount += 1
                    if holdCount > 4{
                        holdCount = 0
                        isExhaling = true
                        isHolding = false
                    }
                }
                if isExhaling{
                    withAnimation(.linear(duration: breathingDuration)){
                        grow = false
                    }
                    exhaleCount += 1
                    if exhaleCount > 6{
                        exhaleCount = 0
                        isExhaling = false
                        isInhaling = true
                        breathsCount += 1
                    }
                }
            }
            if breathsCount == 3{
                breathing = false
                isInhaling = false
                standingBy = true
            }
            
        }
        
        .onReceive(timer2){_ in
            if standingBy{
                withAnimation(.linear(duration: 2)){
                    waiting.toggle()
                }
            }
        }
    }
}
