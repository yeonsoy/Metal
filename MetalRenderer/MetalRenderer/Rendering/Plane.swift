//
//  Plane.swift
//  MetalRenderer
//
//  Created by leesy on 2023/02/14.
//

import Foundation
import MetalKit

class Plane: Node {
    let positionArray: [SIMD4<Float>] = [
        SIMD4<Float>(-0.5, -0.5, 0, 0.7),
        SIMD4<Float>(0.5, -0.5, 0, 0.7),
        SIMD4<Float>(-0.5, 0.5, 0, 1),
        SIMD4<Float>(0.5, 0.5, 0, 1)
    ]
    
    let colorArray: [SIMD3<Float>] = [
        SIMD3<Float>(1, 0, 0),
        SIMD3<Float>(0, 1, 0),
        SIMD3<Float>(0, 0, 1),
        SIMD3<Float>(1, 0, 1)
    ]
    
    let indexArray: [uint16] = [
        0, 1, 2,
        2, 1, 3
    ]
    
    let pipelineState: MTLRenderPipelineState
    let positionBuffer: MTLBuffer
    let colorBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    
    init(name: String) {
        pipelineState = Plane.createPipelineState()
        let positionLength = MemoryLayout<SIMD4<Float>>.stride * positionArray.count
        positionBuffer = Renderer.device.makeBuffer(bytes: positionArray, length: positionLength, options: [])!
        let colorLength = MemoryLayout<SIMD3<Float>>.stride * colorArray.count
        colorBuffer = Renderer.device.makeBuffer(bytes: colorArray, length: colorLength, options: [])!
        let indexLength = MemoryLayout<uint16>.stride * indexArray.count
        indexBuffer = Renderer.device.makeBuffer(bytes: indexArray, length: indexLength, options: [])!
        super.init()
    }
    
    static func createPipelineState() -> MTLRenderPipelineState {
        let functionConstants = MTLFunctionConstantValues()
        let vertexFunction = Renderer.library.makeFunction(name: "vertex_plane")
        let fragmentFrunction = try! Renderer.library.makeFunction(name: "fragment_plane",
                                                                   constantValues: functionConstants)
        // pipeline state properties
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFrunction
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        commandEncoder.setRenderPipelineState(pipelineState)
        
        var wave = deltaTime
        commandEncoder.setVertexBytes(&wave,
                                      length: MemoryLayout<Float>.stride,
                                      index: 2)
        commandEncoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: indexArray.count,
                                             indexType: .uint16,
                                             indexBuffer: indexBuffer,
                                             indexBufferOffset: 0)
    }
}

extension Plane: Renderable {
    func render(commandEncoder: MTLRenderCommandEncoder, uniforms vertex: Uniforms, fragmentUniforms fragment: FragmentUniforms, deltaTime: Float) {
        render(commandEncoder: commandEncoder, deltaTime: deltaTime)
    }
}
