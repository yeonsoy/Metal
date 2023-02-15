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
    let depthStencilState: MTLDepthStencilState
    var timer: Float = 0
    
    weak var scene: Scene?
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()!
        depthStencilState = Renderer.createDepthState()
        
        view.depthStencilPixelFormat = .depth32Float
        
        super.init()
    }
    
    static func createDepthState() -> MTLDepthStencilState {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
    }
}

extension Renderer: MTKViewDelegate {
    // 사용자가 macOS 창의 크기를 조정하거나 iOS 기기를 회전할 때와 같이 보기의 크기가 변경될 때 발생.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene?.sceneSizeWillChange(to: size)
    }
    
    // 모든 프레임에서 실행. GPU 상호 작용 실행 함수.
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
            let scene = scene else {
            return
        }
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        commandEncoder.setDepthStencilState(depthStencilState)
        
        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        scene.update(deltaTime: deltaTime)
        
        timer += 0.05
        for renderable in scene.renderables {
            commandEncoder.pushDebugGroup(renderable.name)
            renderable.render(commandEncoder: commandEncoder,
                              uniforms: scene.uniforms,
                              fragmentUniforms: scene.fragmentUniforms,
                              deltaTime: timer)
            commandEncoder.popDebugGroup()
        }
        
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
