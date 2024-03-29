//
//  Cameras.swift
//  MetalRenderer
//
//  Created by leesy on 2022/12/22.
//

import Foundation
import MetalKit

class Camera: Node {
    var fov = radians(fromDegrees: 60)
    var near: Float = 0.01
    var far: Float = 100
    var aspect: Float = 1
    
    var viewMatrix: float4x4 {
        let translateMatrix = float4x4(translation: position)
        let rotateMatrix = float4x4(rotation: rotation)
        let scaleMatrix = float4x4(scaling: scale)
        return (translateMatrix * scaleMatrix * rotateMatrix).inverse
    }
    
    var projectionMatrix: float4x4 {
        return float4x4(projectionFov: fov,
                        near: near,
                        far: far,
                        aspect: aspect)
    }
    
    func zoom(delta: Float) {}
    func rotate(delta: SIMD2<Float>) {}
}

class ArcballCamera: Camera {
    
    var minDistance: Float = 0.5
    var maxDistance: Float = 10
    var distance: Float = 0 {
        didSet {
            _viewMatrix = updateViewMatrix()
        }
    }
    var target = SIMD3<Float>(repeating: 0) {
        didSet {
            _viewMatrix = updateViewMatrix()
        }
    }
    
    override var viewMatrix: float4x4 {
        return _viewMatrix
    }
    private var _viewMatrix = float4x4.identity
    
    override init() {
        super.init()
        _viewMatrix = updateViewMatrix()
    }
    
    private func updateViewMatrix() -> float4x4 {
        let translateMatrix = float4x4(translation: [target.x, target.y, target.z - distance])
        let rotateMatrix = float4x4(rotationYXZ: [-rotation.x,
                                                   rotation.y,
                                                   0])
        let matrix = (rotateMatrix * translateMatrix).inverse
        position = rotateMatrix.upperLeft * -matrix.columns.3.xyz
        return matrix
    }
    
    override func zoom(delta: Float) {
        let sensitivity: Float = 0.05
        distance -= delta * sensitivity
        _viewMatrix = updateViewMatrix()
    }
    
    override func rotate(delta: SIMD2<Float>) {
        let sensitivity: Float = 0.005
        rotation.y += delta.x * sensitivity
        rotation.x += delta.y * sensitivity
        rotation.x = max(-Float.pi/2,
                                    min(rotation.x,
                                        Float.pi/2))
        _viewMatrix = updateViewMatrix()
    }
}



