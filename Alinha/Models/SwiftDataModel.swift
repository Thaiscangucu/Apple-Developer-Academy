//
//  SwiftDataModel.swift
//  Front
//
//  Created by Jonas Fernando Nascimento Melo on 03/09/25.
//
import Foundation
import SwiftUI
import SwiftData

var deviceToken_: String? = nil

@Model
class User {
    var authID: String
    var imageName: String
    var name: String
    var email: String
    var role: String
    var id: UUID
    var deviceToken: String?
    
    init(authID: String, imageName: String, name: String, email: String, role: String, id: UUID, deviceToken: String? = nil) {
        self.authID = authID
        self.imageName = imageName
        self.name = name
        self.email = email
        self.role = role
        self.id = id
        self.deviceToken = deviceToken
    }
}
