//
//  GameScene.swift
//  MetalRenderer
//
//  Created by leesy on 2023/01/11.
//

import Foundation

class GameScene: Scene {
    
    override func setupScene() {
        camera.target = [0, 0.8, 0]
        camera.distance = 8
        camera.rotation = [-0.4, -0.4, 0]
        
        let train = Instance(name: "train", instanceCount: 100)
        add(node: train)
        for i in 0..<100 {
            train.transforms[i].position.x = Float.random(in: -5..<5)
            train.transforms[i].position.z = Float.random(in: 0..<10)
            train.transforms[i].rotation.y = Float.random(in: 0..<radians(fromDegrees: 359))
        }
    }
}
