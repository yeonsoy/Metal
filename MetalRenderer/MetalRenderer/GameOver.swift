//
//  GameOver.swift
//  MetalRenderer
//
//  Created by leesy on 2023/02/13.
//

import Foundation

class GameOver: Scene {
    var win = false {
        didSet {
            print("GAME OVER -", win ? "You Won" : "You Lost")
        }
    }
    
    override func click(location: float2) {
        let scene = RayBreak(sceneSize: sceneSize)
        sceneDelegate?.transition(to: scene)
    }
}
