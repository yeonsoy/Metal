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
    let depthStencilState: MTLDepthStencilState
    
    let train: Model
    let tree: Model
    let camera = Camera()
    
    var uniforms = Uniforms()
    
    init(view: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Unable to connect to GPU")
        }
        Renderer.device = device
        self.commandQueue = commandQueue
        Renderer.library = device.makeDefaultLibrary()!
        pipelineState = Renderer.createPipelineState()
        depthStencilState = Renderer.createDepthState()
        
        view.depthStencilPixelFormat = .depth32Float
        
        train = Model(name: "train")
        train.transform.position = [0.4, 0, 0]
        train.transform.scale = 0.5
        
        tree = Model(name: "treefir")
        tree.transform.position = [-1, 0, 0.3]
        tree.transform.scale = 0.5
        
        camera.transform.position = [0, 0.5, -3]
        
        super.init()
    }
    
    static func createDepthState() -> MTLDepthStencilState {
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: depthDescriptor)!
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
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        return try! Renderer.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }
    
    func zoom(delta: Float) {
        let sensitivity: Float = 0.05
        let cameraVector = camera.transform.matrix.upperLeft.columns.2
        camera.transform.position += delta * sensitivity * cameraVector
    }
}

extension Renderer: MTKViewDelegate {
    // 사용자가 macOS 창의 크기를 조정하거나 iOS 기기를 회전할 때와 같이 보기의 크기가 변경될 때 발생.
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(view.bounds.width / view.bounds.height)
    }
    
    // 모든 프레임에서 실행. GPU 상호 작용 실행 함수.
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setDepthStencilState(depthStencilState)
        
        uniforms.viewMatrix = camera.viewMatrix
        uniforms.projectionMatrix = camera.projectionMatrix
        
        let models = [tree, train]
        for model in models {
            uniforms.modelMatrix = model.transform.matrix
            commandEncoder.setVertexBytes(&uniforms,
                                          length: MemoryLayout<Uniforms>.stride,
                                          index: 21)
            
            for mtkMesh in model.mtkMeshes {
                for vertexBuffer in mtkMesh.vertexBuffers {
                    commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
                    
                    var color = 0
                    for submesh in mtkMesh.submeshes {
                        commandEncoder.setVertexBytes(&color, length: MemoryLayout<Int>.stride, index: 11)
                        // draw call
                        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                                             indexCount: submesh.indexCount,
                                                             indexType: submesh.indexType,
                                                             indexBuffer: submesh.indexBuffer.buffer,
                                                             indexBufferOffset: submesh.indexBuffer.offset)
                        color += 1
                    }
                }
            }
        }
        
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
