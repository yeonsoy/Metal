//
//  GameScene.swift
//  MetalRenderer
//
//  Created by leesy on 2023/01/11.
//

import Foundation

class GameScene: Scene {
    let train = Model(name: "train")
    let tree = Model(name: "treefir")
    
    override func setupScene() {
        camera.target = [0, 0.8, 0]
        camera.distance = 4
        camera.rotation = [-0.4, -0.4, 0]
        
        add(node: train)
        add(node: tree)
        tree.position.x = -2.0
    }
}
