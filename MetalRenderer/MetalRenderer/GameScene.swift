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
        add(node: train)
        add(node: tree)
        tree.position.x = -2.0
    }
}
