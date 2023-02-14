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

        camera.distance = 15
        camera.fov = radians(fromDegrees: 100)
    }
}
