//
//  Misc.swift
//  POCNetWorkGameCenter
//
//  Created by Vinicius Marques on 11/02/26.
//

import SwiftUI

enum PlayerAuthState: String{
    case authenticated = ""
    case authenticating = "Loading in to Game Center.."
    case unauthenticated = "Sing in.."
    case error = "There was an error loggin into Game Center"
    case restricted = "You are not allowed to play multiplayer games!"

}

let maxTimeRemaining = 100
