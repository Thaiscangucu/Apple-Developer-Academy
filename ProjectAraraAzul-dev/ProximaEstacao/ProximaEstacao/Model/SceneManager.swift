//
//  SceneManager.swift
//  ProximaEstacao
//
//  Created by Vinicius Marques on 04/03/26.
//
import SpriteKit

@MainActor
final class SceneManager {

    static let shared = SceneManager()

    var currentScene: CustomScene

    private init() {
        currentScene = CustomScene(
            size: CGSize(width: 1920, height: 1080),
            matchManager: MatchManagerViewModel.shared
        )
    }
}

