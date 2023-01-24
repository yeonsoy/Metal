//
//  GameScene.swift
//  MetalRenderer
//
//  Created by leesy on 2023/01/11.
//

import Foundation

class GameScene: Scene {
    let train = Model(name: "train")
    let trees = Instance(name: "treefir", instanceCount: 100)
    
    override func setupScene() {
        camera.target = [0, 0.8, 0]
        camera.distance = 4
        camera.rotation = [-0.4, -0.4, 0]
        
        add(node: train)
        add(node: trees)
        
        for i in 0..<100 {
            trees.transforms[i].position.x = Float(i) - 50
            trees.transforms[i].position.z = 2
        }
    }
}
