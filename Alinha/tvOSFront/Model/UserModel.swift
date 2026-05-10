//
//  UserModel.swift
//  Front
//
//  Created by Thais Cangucu on 26/08/25.
//
import SwiftUI
import Foundation

struct UserModel: Codable, Identifiable {
    var name: String
    var password: String
    var path: String
    var role: String
    var email: String
    var id: UUID
}

//struct UserModel: Codable{
//    var mentor: String
//    var student: String
//    var appointmentPlace: String
//    var description: String
//    var type: String
//    var path: String
//}
//
//struct UserModel: Codable, Identifiable{
//    var id: UUID
//    var mentor: String
//    var studentID: UUID
//    var description: String
//    var appoitmentPlace: String
//    var isScheduled: Bool
//    var callStudent: Bool
//    var isDone: Bool
//    var createdAt: Date
//    var type: String
//    var path: String
//
//}

//struct Atendimento: Codable, Identifiable {
//    var mentor: String
//    var local: String
//    var aluno: String
//    var tipo: String
//
//}
//
//struct Mentor: Codable, Identifiable {
//    var nome: String
//    var disponivel: Bool
//    var local: String
//}
//
//struct Local Codable, Identifiable {
//    var nome: String
//}
//
//struct Aluno Codable, Identifiable {
//    var name: String
//    var password: String
//    var path: String
//    var role: String
//    var email: String
//    var id: UUID
//}
