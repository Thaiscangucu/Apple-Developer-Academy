import SwiftUI

struct ActivityPage: View {
    
    @State private var tabView = 0
    
    
    var body: some View {
        NavigationStack{
            HStack{
                Spacer()
                Text("Activity")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink{
                    Settings()
                }
                label:{
                    Image(systemName: "slider.horizontal.3")
                    
                }
                
//                Label("", systemImage: "slider.horizontal.3")
            }
            Picker("", selection: $tabView) {
                Text("Friends").tag(0)
                Text("You").tag(1)
                Text("Incoming").tag(2)
            }
            .pickerStyle(.segmented)
            
            ScrollView(.vertical){
                
                
                    VStack{
                        HStack{
//                        HStack{
                            Label("", systemImage: "person.circle.fill")
                                .font(.largeTitle)
                            Text("username played")
                                .foregroundStyle(.gray)
                                .font(.caption)
                                .fontWeight(.medium)
                            Spacer()
                        }
//                        .padding(.leading, -200)
                        .foregroundStyle(.gray)
                        
                        HStack{
                            Text("The Last Of Us Part II")
                                .bold()
//                                .padding(.leading,47)
                            Text("2020")
                                .font(.caption)
                            Spacer()
                        }
//                        .padding(.leading, -135.0)
                        
                        HStack{
                            FiveStars()
//                                .padding(.leading, -140)
                                .foregroundStyle(.accent)
                            Label("", systemImage: "heart.fill")
//                                .padding(.leading, -70)
                               
                                .foregroundStyle(.purple)
                                .font(.caption)
                            Spacer()
                        }
                        
                        HStack{
                            Image("tlou2")
                                .resizable()
                                .frame(width: 70, height: 100)
                                .shadow(radius: 3)
                                .border(.gray)
                                .cornerRadius(3)
                            Text("Lorem ipsum dolor sit amet. Sed voluptatem velit sit perferendis adipisci ad vitae voluptatem ab quod numquam aut inventore aliquam ea minus.")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .bold()
                            Spacer()
                        }
//                        .padding(.leading, 57.0)
                         
                        
                        ZStack{
                            
                            Rectangle()
                                .frame(width: .infinity, height: 165)
                                .foregroundStyle(.darkgray)
                            VStack{
                                HStack{
                                    Label("", systemImage: "person.circle.fill")
                                        .font(.largeTitle)
                                    Text("""
                                         username liked username's \(Image(systemName: "star.fill")) review of Hades
                                        """)
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    Spacer()
                                    
                                }
                                .foregroundStyle(.gray)
                                .padding(.leading, 1.0)
                                DividerLine(width: .infinity)
                                    .foregroundStyle(.gray)
                                
                                HStack{
                                    Label("", systemImage: "person.circle.fill")
                                        .font(.largeTitle)
                                    Text("""
                                         username liked username's \(Image(systemName: "star.fill")) review of EAFC 25
                                        """)
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    Spacer()
                                }
                                .foregroundStyle(.gray)
                                .padding(.leading, 1.0)

                                DividerLine(width: .infinity)
                                    .foregroundStyle(.gray)
                                
                                HStack{
                                    Label("", systemImage: "person.circle.fill")
                                        .font(.largeTitle)
                                        
                                    Text("""
                                         username liked username's \(Image(systemName: "star.fill")) review of League of Legends
                                        """)
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    Spacer()
                                }
                                .foregroundStyle(.gray)
                                .padding(.leading, 1.0)

                               
                            }
                            
                        }
                        
                        
                        
                        
                        VStack{
                            HStack{
                                Label("", systemImage: "person.circle.fill")
                                    .font(.largeTitle)
                                
                                Text("username played")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                
                                Spacer()
                            }
//                            .padding(.leading, -200.0)
                            .foregroundStyle(.gray)
                            
                            
                            HStack{
                                Text("Undertale")
                                    .bold()
//                                    .padding(.leading,-10)
                                Text("2020")
                                    .font(.caption)
                                Spacer()
                            }
//                            .padding(.leading, -135)
                            
                            HStack{
                                FiveStars()
//                                    .padding(.leading, -146)
                                    .foregroundStyle(.accent)
                                Spacer()
                            }
                            HStack{
                                Image("Undertale")
                                    .resizable()
                                    .frame(width: 70, height: 100)
                                    .shadow(radius: 3)
                                    .border(.gray)
                                    .cornerRadius(3)
                                Text("Lorem ipsum dolor sit amet. Sed voluptatem velit sit perferendis adipisci ad vitae voluptatem ab quod numquam aut inventore aliquam ea minus.")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .bold()
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }

