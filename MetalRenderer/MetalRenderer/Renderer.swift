//
//  Renderer.swift
//  MetalRenderer
//
//  Created by leesy on 2022/12/08.
//

import Foundation
import MetalKit

struct Vertex {
    let position: SIMD3<Float>
    let color: SIMD3<Float>
}

class Renderer: NSObject {
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    static var library: MTLLibrary!
    let pipelineState: MTLRenderPipelineState
    
    let vertices: [Vertex] = [
        Vertex(position: SIMD3<Float>(-0.5, -0.2, 0), color: SIMD3<Float>(1, 0, 0)),
        Vertex(position: SIMD3<Float>(0.2, -0.2, 0), color: SIMD3<Float>(0, 1, 0)),
        Vertex(position: SIMD3<Float>(0, 0.5, 0), color: SIMD3<Float>(0, 0, 1)),
        Vertex(position: SIMD3<Float>(0.7, 0.7, 0), color: SIMD3<Float>(1, 0, 1))
    ]

    let indexArray: [uint16] = [
        0, 1, 2,
        2, 1, 3
    ]
    
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()!
        pipelineState = Renderer.createPipelineState()
        
        let vertexLength = MemoryLayout<Vertex>.stride * vertices.count
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexLength, options: [])!
        let indexLength = MemoryLayout<uint16>.stride * indexArray.count
        indexBuffer = device.makeBuffer(bytes: indexArray, length: indexLength, options: [])!
        
        super.init()
    }
    
    static func createPipelineState() -> MTLRenderPipelineState {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        
        // pipeline state properties
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let vertexFunction = Renderer.library.makeFunction(name: "vertex_main")
        let fragmentFrunction = Renderer.library.makeFunction(name: "fragment_main")
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFrunction
        pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultVertexDescriptor()
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
}

extension Renderer: MTKViewDelegate {
    // 사용자가 macOS 창의 크기를 조정하거나 iOS 기기를 회전할 때와 같이 보기의 크기가 변경될 때 발생.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    // 모든 프레임에서 실행. GPU 상호 작용 실행 함수.
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
        let descriptor = view.currentRenderPassDescriptor,
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        commandEncoder.setRenderPipelineState(pipelineState)
        
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // draw call
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: indexArray.count,
                                             indexType: .uint16,
                                             indexBuffer: indexBuffer,
                                             indexBufferOffset: 0)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
