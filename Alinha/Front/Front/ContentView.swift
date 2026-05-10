//
//  ContentView.swift
//  Front
//
//  Created by Jonas Fernando Nascimento Melo on 20/08/25.
//

import SwiftUI
enum AppRoute {
    case ProfileView
    case LoginView
    case CreatAccoutView
}
struct ContentView: View {
    
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path){
            VStack{
                LoginView(path: $path)
                    .modelContainer(for: User.self)
                    .navigationDestination(for: AppRoute.self){ route in
                        switch route {
                        case .ProfileView:
                            ProfileView(userIcon: "icon1",path: $path)
                                .modelContainer(for: User.self)

                        case .LoginView:
                            LoginView(path: $path)
                            
                        case .CreatAccoutView:
                            CreateAccountView(path: $path)
                        }
                    }
            }
//            .onAppear{
//                path.append(AppRoute.LoginView)
//            }
            
            //            VStack {
            //                LoginView(statusCode: .ok, path: $path)
            //            }
            //            .modelContainer(for: UserInfoLogIn.self)
            //        }
        }
    }
}


//
//#Preview {
//    ContentView()
//}
