//
//  HabitsView.swift
//  Inheal
//
//  Created by Thais Cangucu on 16/01/26.
//

import SwiftUI

struct HabitsView: View {
    @State private var showingSheet = false
    
    var HabitsWidth: CGFloat = 500
    var HabitsHeight: CGFloat  = 600

    @State var todos: [ToDo] = [
        ToDo(title: "Drink Water", isDone: false),
        ToDo(title: "Sleep 8 hours", isDone: false),
        ToDo(title: "Exercise", isDone: false),
        ToDo(title: "Meditade", isDone: false)
    ]
    var facts: [Fact] = [
        Fact(title: "What is progressive muscle relaxation?", content: "Progressive muscle relaxation (PMR) is a type of grounding technique that involves slowly tensing and then relaxing different muscle groups in your body. Doing this in a calm, mindful way can help you notice where your body is holding stress and give you a way to let go of it.", source: "https://www.lifeline.org.au"),
        Fact(title: "How to do a diaphragmatic breathing", content: "• Lie on your back on a flat surface (or in bed) with your knees bent. You can use a pillow under your head and your knees for support, if that's more comfortable.• Place one hand on your upper chest and the other on your belly, just below your rib cage. \n* Breathe in slowly through your nose, letting the air in deeply, towards your lower belly. The hand on your chest should remain still, while the one on your belly should rise.\n• Tighten your abdominal muscles and let them fall inward as you exhale through pursed lips. The hand on your belly should move down to its original position.", source: "https://www.health.harvard.edu"),
        Fact(title: "The Vagus Nerve & Exhalation", content: "• The Vagus Nerve is the main component of your parasympathetic nervous system. When you focus on a long, slow exhale (specifically longer than your inhale), you physically stimulate this nerve, which acts as a natural brake' on your heart rate and stress response.", source: "https://pmc.ncbi.nlm.nih.gov"),
        Fact(title: "The 5-4-3-2-1 Sensory Grounding", content: "• During an anxiety spiral, the amygdala (fear center) is overactive. By naming specific sensory inputs, you force the prefrontal cortex (the logical, grounding part of the brain) to take over, which interrupts the cycle of intrusive thoughts.", source: "https://www.urmc.rochester.edu/"),
        Fact(title: "Cold Water & The Mammalian Dive Reflex", content: "• Splashing cold water on your face triggers the 'Mammalian Dive Reflex.' This is an ancient biological survival mechanism that immediately slows the heart rate and redirects blood flow to the heart and brain, providing a near-instant 'hard reset' for a panic attack.", source: "https://www.frontiersin.org/"),
        Fact(title: "Box Breathing (4-4-4-4)", content: "• Box breathing is used by elite athletes and Navy SEALs because the rhythmic counting provides a 'cognitive load' that occupies the brain, while the slow oxygen intake stabilizes the Autonomic Nervous System (ANS), reducing the feeling of 'fight or flight.'", source: "https://www.goodrx.com/"),
        Fact(title: "Proprioceptive Input (Deep Pressure)", content: "• Deep pressure (like a weighted blanket or a firm hug) provides proprioceptive input. This sends signals to the brain about where the body is in space, which increases the release of serotonin and dopamine while decreasing cortisol, helping the nervous system feel safe.'", source: "https://www.mdpi.com/"),
        
    ]
    
    @State var randomFact: Fact = Fact(title: "", content: "", source: "")
    @State var randomFact2: Fact = Fact(title: "", content: "", source: "")
    var body: some View {
        ZStack{
            Background()
            HStack(spacing: 30){
                VStack(alignment: .leading){
                    Text("Healthy Habits")
                        .font(.title2)
                        .bold()
                        .padding(.bottom)
                    
                    // Tasks list
                    VStack(alignment: .leading){
                        ForEach(todos){ todo in
                            HStack(alignment: .center) {
                                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                                    .imageScale(.large)
                                    .foregroundColor(.accentColor)
                                    .onTapGesture {
                                        toggleDone(todo)
                                    }
                                Text(todo.title)
                                    .bold()
                                    .padding(.leading, 5)
                            }
                            .padding(.vertical, 2)
                            .swipeActions {
                                Button(role: .destructive) {
                                    deleteToDo(todo)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                            Divider()
                        }
                        Spacer()
                        
//                        //Plus Button
//                        HStack{
//                            Spacer()
//                            Button {
//                                showingSheet.toggle()
//                            } label: {
//                                ZStack{
//                                    Circle()
//                                        .frame(width: 45, height: 45)
//                                    Image(systemName: "plus")
//                                        .foregroundStyle(.white)
//                                }
//                            }
//                        }
//                        .sheet(isPresented: $showingSheet, onDismiss: {
//                        }) {
//                            FormView(todos: $todos)
//                        }
                    }
                    .padding(20)
                    .background{
                        RoundedRectangle(cornerRadius: 32)
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: HabitsWidth, maxHeight: HabitsHeight)
                .padding(30)
                .background{
                    RoundedRectangle(cornerRadius: 32)
                        .foregroundStyle(.white)
                        .opacity(0.7)
                }
                
                // Facts 
                VStack(spacing: 60){
                    FactsCard(fact: randomFact)
                    FactsCard(fact: randomFact2)
                }
                .padding()
            }
            .padding(35)
        }
        .onAppear {
            let shuffledFacts = facts.shuffled()
            if shuffledFacts.count >= 2 {
                randomFact = shuffledFacts[0]
                randomFact2 = shuffledFacts[1]
            }
        }
        .preferredColorScheme(.light)
    }
    
    func toggleDone(_ todo: ToDo) {
        for i in 0..<todos.count {
            if todos[i].id == todo.id {
                todos[i].isDone.toggle()
            }
        }
    }
    func deleteToDo(_ todo: ToDo) {
        for i in 0..<todos.count {
            if todos[i].id == todo.id {
                todos.remove(at: i)
            }
        }
    }
}

struct ToDo: Hashable, Identifiable{
    var id = UUID()
    var title: String
    var isDone: Bool
}
struct Fact: Hashable{
    var title: String
    var content: String
    var source: String
}

//struct FormView: View {
//    @Binding var todos: [ToDo]
//    @Environment(\.dismiss) var dismiss
//    
//    @State var title: String = ""
//    @State var desc: String = ""
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Form {
//                    TextField("Title", text: $title)
//                }
//            }
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Add") {
//                        todos.append(ToDo(title: title, isDone: false))
//                        dismiss()
//                    }
//                }
//                
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//            }
//            .navigationTitle("Create")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}



#Preview(traits: .landscapeLeft){
    HabitsView()
}
