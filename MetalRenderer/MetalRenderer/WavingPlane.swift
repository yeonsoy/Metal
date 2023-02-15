//
//  WavingPlain.swift
//  MetalRenderer
//
//  Created by leesy on 2023/02/14.
//

import Foundation

class WavingPlain: Scene {
    override func setupScene() {
        let plane = Plane(name: "Plane")
        add(node: plane)
        camera.distance = 0.45
        camera.position = [-0.4, 0.07, -0.2]
        camera.rotation = [-1.5, 1.5, 0]
    }
    
    override func updateScene(deltaTime: Float) {
        print(camera.distance, camera.position, camera.rotation)
    }
}
