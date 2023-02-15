//
//  Plane.swift
//  MetalRenderer
//
//  Created by leesy on 2023/02/14.
//

import Foundation
import MetalKit

class Plane: Node {
    let meshes: [Mesh]
    
    init(name: String) {
        let assetUrl = Bundle.main.url(forResource: "ball", withExtension: "obj")!
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        
        let vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor()
        let asset = MDLAsset(url: assetUrl,
                             vertexDescriptor: vertexDescriptor,
                             bufferAllocator: allocator)
        
        asset.loadTextures()
        
        let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(asset: asset, device: Renderer.device)
        
        meshes = zip(mdlMeshes, mtkMeshes).map {
            Mesh(mdlMesh: $0.0, mtkMesh: $0.1)
        }
        
        super.init()
        self.name = name
        self.boundingBox = mdlMeshes[0].boundingBox
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, submesh: Submesh) {
        let mtkSubmesh = submesh.mtkSubmesh

        // draw call
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: mtkSubmesh.indexCount,
                                             indexType: mtkSubmesh.indexType,
                                             indexBuffer: mtkSubmesh.indexBuffer.buffer,
                                             indexBufferOffset: mtkSubmesh.indexBuffer.offset)
    }
}

extension Plane: Renderable {
    func render(commandEncoder: MTLRenderCommandEncoder, uniforms vertex: Uniforms, fragmentUniforms fragment: FragmentUniforms, deltaTime: Float) {
        
        var uniforms = vertex
        var fragmentUniforms = fragment
        
        uniforms.modelMatrix = worldMatrix
        var wave = deltaTime
        commandEncoder.setVertexBytes(&wave,
                                      length: MemoryLayout<Float>.stride,
                                      index: 2)
        commandEncoder.setVertexBytes(&uniforms,
                                      length: MemoryLayout<Uniforms>.stride,
                                      index: 21)
        commandEncoder.setFragmentBytes(&fragmentUniforms,
                                       length: MemoryLayout<FragmentUniforms>.stride,
                                       index: 22)
        
        for mesh in meshes {
            for vertexBuffer in mesh.mtkMesh.vertexBuffers {
                commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
                
                for submesh in mesh.submeshes {
                    commandEncoder.setRenderPipelineState(submesh.planePipelineState)
                    var material = submesh.material
                    commandEncoder.setFragmentBytes(&material,
                                                    length: MemoryLayout<Material>.stride,
                                                    index: 11)
                    commandEncoder.setFragmentTexture(submesh.textures.baseColor, index: 0)
                    render(commandEncoder: commandEncoder, submesh: submesh)
                }
            }
        }
    }
}
