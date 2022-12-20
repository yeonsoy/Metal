//
//  Renderer.swift
//  MetalRenderer
//
//  Created by leesy on 2022/12/08.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    let commandQueue: MTLCommandQueue
    static var library: MTLLibrary!
    let pipelineState: MTLRenderPipelineState
    
    let positionArray: [SIMD4<Float>] = [
        SIMD4<Float>(-0.5, -0.2, 0, 1),
        SIMD4<Float>(0.2, -0.2, 0, 1),
        SIMD4<Float>(0, 0.5, 0, 1),
        SIMD4<Float>(0, 0.5, 0, 1),
        SIMD4<Float>(0.2, -0.2, 0, 1),
        SIMD4<Float>(0.7, 0.7, 0, 1)
    ]
    
    let colorArray: [SIMD3<Float>] = [
        SIMD3<Float>(1, 0, 0),
        SIMD3<Float>(0, 1, 0),
        SIMD3<Float>(0, 0, 1),
        SIMD3<Float>(0, 0, 1),
        SIMD3<Float>(0, 1, 0),
        SIMD3<Float>(1, 0, 1)
    ]
    
    let positionBuffer: MTLBuffer
    let colorBuffer: MTLBuffer
    
    var timer: Float = 0
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()!
        pipelineState = Renderer.createPipelineState()
        
        let positionLength = MemoryLayout<SIMD4<Float>>.stride * positionArray.count
        positionBuffer = device.makeBuffer(bytes: positionArray, length: positionLength, options: [])!
        let colorLength = MemoryLayout<SIMD3<Float>>.stride * colorArray.count
        colorBuffer = device.makeBuffer(bytes: colorArray, length: colorLength, options: [])!
        
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
        
        timer += 0.05
        var currentTime = sin(timer)
        
        commandEncoder.setVertexBytes(&currentTime,
                                      length: MemoryLayout<Float>.stride,
                                      index: 2)
        commandEncoder.setRenderPipelineState(pipelineState)
        
        commandEncoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        
        // draw call
        commandEncoder.drawPrimitives(type: .triangle,
                                      vertexStart: 0,
                                      vertexCount: 6)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
