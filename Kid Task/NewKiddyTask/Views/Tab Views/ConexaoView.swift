//
//  ContentView.swift
//  NewKiddyTask
//
//  Created by Thais Cangucu on 28/01/26.
//

import SwiftUI

struct Person: Identifiable{
    var id = UUID()
    var name: String
    var cargo: String
    var num: String
    var email: String
}

struct ConexaoView: View {
    var people: [Person] = [
        Person(name: "Dra Patrícia", cargo: "Psicopedagoga", num: "+11 91234-5678", email: "patriciaramos@gmail.com"),
        Person(name: "Dra. Carol", cargo: "Terapeuta Ocupacional", num: "+11 91234-5678", email: "carol@gmail.com"),
        Person(name: "Dra. Rosana", cargo: "Psicopedagoga", num: "+11 91234-5678", email: "rosana@gmail.com"),
        Person(name: "Dr. Felipe", cargo: "Piscoterapeuta", num: "+11 91234-5678", email: "felipe@gmail.com"),
    ]
    @State var isOpen = false
    @State private var selectedPersonID: UUID? = nil
    
    var filteredPeople: [Person] {
        if searchText.isEmpty {
            return people
        } else {
            return people.filter { person in
                // Verifica se o texto digitado existe no NOME ou no CARGO
                let matchName = person.name.localizedCaseInsensitiveContains(searchText)
                let matchCargo = person.cargo.localizedCaseInsensitiveContains(searchText)
                
                // Retorna verdadeiro se encontrar em qualquer um dos dois
                return matchName || matchCargo
            }
        }
    }
    @State private var searchText = ""
    let items = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]
    
    @State var relatorioSheet = false
    var body: some View {
        NavigationStack{
            ZStack{
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack{
                    //Tool Bar
                    HStack{
                        Spacer()
                        Button{
                            relatorioSheet.toggle()
                        }label:{
                            Image(systemName: "list.bullet.clipboard.fill")
                                .foregroundColor(Color(red: 0.53, green: 0.67, blue: 0.73))
                                .font(.system(size: 28))
                        }
                    }
                    .padding(.bottom)
                    .padding(.horizontal)
                    
                    // Search bar
                    HStack(spacing: 12){
                        ZStack{
                            Circle()
                                .foregroundStyle(Color(red: 0.81, green: 0.91, blue: 0.97))
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .foregroundStyle(Color(red: 0.51, green: 0.72, blue: 0.81))
                                .font(.system(size: 19))
                        }
                        .frame(width: 50, height: 50)
                        CustomSearchBar(text: $searchText)
                    }
                    
                    // Lista professionais
                    Text("Profissionais que você pode precisar")
                        .font(.custom("Qilka", size: 18)
                            .weight(.bold)
                        )
                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                        .padding(.top, 30)
                    
                    ForEach(filteredPeople) { person in
                        VStack(spacing: 0) {
                            HStack {
                                ZStack{
                                    Rectangle()
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    Image(systemName: "person.fill")
                                        .font(.title)
                                        .foregroundStyle(Color(red: 0.53, green: 0.67, blue: 0.73))
                                }
                                .frame(width: 49, height: 40)
                                VStack(alignment: .leading) {
                                    Text(person.name)
                                        .font(.custom("Qilka", size: 18).weight(.bold))
                                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                                    Text(person.cargo)
                                        .font(.system(size: 12))
                                        .fontWeight(.light)
                                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                                }
                                
                                Spacer()
                                
                                Group {
                                    Image(systemName: "phone.fill")
                                    Image(systemName: "envelope.fill")
                                }
                                .foregroundColor(Color(red: 0.53, green: 0.67, blue: 0.73))
                                .font(.system(size: 25))
                            }
                            .padding()
                            .frame(height: 60)
                            
                            
                            if selectedPersonID == person.id {
                                VStack(alignment: .leading, spacing: 16){
                                    HStack{
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(Color(red: 0.53, green: 0.67, blue: 0.73))
                                            .font(.system(size: 25))
                                        Text(person.num)
                                            .font(Font.custom("SF Compact Rounded", size: 16))
                                            .foregroundColor(Color(red: 0.53, green: 0.67, blue: 0.73))
                                    }
                                    HStack{
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(Color(red: 0.53, green: 0.67, blue: 0.73))
                                            .font(.system(size: 25))
                                        Text(person.email)
                                            .font(Font.custom("SF Compact Rounded", size: 16))
                                            .foregroundColor(Color(red: 0.53, green: 0.67, blue: 0.73))
                                            .padding(.bottom)
                                    }
                                }
                                // Garante que o conteúdo extra apareça com transição
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .frame(width: 323)
                        // Altura dinâmica: se selecionado, cresce. Se não, fica em 60.
                        .frame(minHeight: 60)
                        .background(
                            Color(red: 0.76, green: 0.86, blue: 0.88)
                                .opacity(0.56)
                                .cornerRadius(20)
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                // Se já estiver aberto, fecha. Se não, abre este.
                                if selectedPersonID == person.id {
                                    selectedPersonID = nil
                                } else {
                                    selectedPersonID = person.id
                                }
                            }
                        }
                    }
                    .padding(.bottom, 19)
                    
                }
                .padding(.bottom, 200)
            }
        }
        .sheet(isPresented: $relatorioSheet){
            Report()
        }
    }
    
}
#Preview {
    ConexaoView()
}

struct CustomSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(red: 0.33, green: 0.58, blue: 0.69))
            TextField("Buscar", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            Image(systemName: "microphone")
                .font(.system(size: 16))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(red: 0.33, green: 0.58, blue: 0.69))
            
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: 245, height: 30)
        .padding(10)
        .background{
            ZStack{
                RoundedRectangle(cornerRadius: 60)
                    .foregroundStyle(Color(red: 0.81, green: 0.91, blue: 0.97))
            }
            
        }
    }
}
