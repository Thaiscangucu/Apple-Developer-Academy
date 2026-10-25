//
//  SplitFlightGeomtry.swift
//  EventsApp
//
//  Created by Camila Parolin on 10/09/26.
//

import SwiftUI

//esse arquivo permite que a honeycomb e o card informem suas posições dentro da SplitView

enum SplitFlightCoordinateSpace {
    static let name = "splitFlightCoordinateSpace"
}

struct HoneycombFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let nextFrame = nextValue()
        
        if !nextFrame.isEmpty {
            value = nextFrame
        }
    }
}

struct CardClusterFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let nextFrame = nextValue()
        
        if !nextFrame.isEmpty {
            value = nextFrame
        }
    }
}

struct HoneycombSelection {
    let userID: User.ID
    let centerInHoneycomb: CGPoint
    let diameter: CGFloat
}

struct CardUserSelection {
    let userID: User.ID
    let index: Int
    let totalCount: Int
}

struct UserGroupFlightItem {
    let user: User
    let centerInView: CGPoint
    let diameter: CGFloat
}
