//
//  Mesh.swift
//  MetalRenderer
//
//  Created by leesy on 2023/01/11.
//

import Foundation
import MetalKit


struct Mesh {
    let mtkMesh: MTKMesh
    let submeshes: [Submesh]
    
    init(mdlMesh: MDLMesh, mtkMesh: MTKMesh) {
        self.mtkMesh = mtkMesh
        submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map {
            Submesh(mdlSubmesh: $0.0 as! MDLSubmesh, mtkSubmesh: $0.1)
        }
    }
}

struct Submesh {
    let mtkSubmesh: MTKSubmesh
    var material: Material
    
    struct Textures {
        let baseColor: MTLTexture?
        
        init(material: MDLMaterial?) {
            guard let baseColor = material?.property(with: .baseColor),
                  baseColor.type == .texture,
                  let mdlTexture = baseColor.textureSamplerValue?.texture else {
                self.baseColor = nil
                return
            }
            let textureLoader = MTKTextureLoader(device: Renderer.device)
            let textureLoaderOptions: [MTKTextureLoader.Option:Any] = [
                .origin: MTKTextureLoader.Origin.bottomLeft
            ]
            self.baseColor = try? textureLoader.newTexture(texture: mdlTexture,
                                                           options: textureLoaderOptions)
        }
    }
    
    let textures: Textures
    let pipelineState: MTLRenderPipelineState
    let instancedPipelineState: MTLRenderPipelineState
    let planePipelineState: MTLRenderPipelineState
    
    init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
        self.mtkSubmesh = mtkSubmesh
        material = Material(material: mdlSubmesh.material)
        textures = Textures(material: mdlSubmesh.material)
        pipelineState = Submesh.createPipelineState(vertexFunctionName: "vertex_main",
                                                    textures: textures)
        instancedPipelineState = Submesh.createPipelineState(vertexFunctionName: "vertex_instances",
                                                             textures: textures)
        planePipelineState = Submesh.createPipelineState(vertexFunctionName: "vertex_plane",
                                                             textures: textures)
    }
    
    static func createPipelineState(vertexFunctionName: String, textures: Textures) -> MTLRenderPipelineState {
        let functionConstants = MTLFunctionConstantValues()
        var property = textures.baseColor != nil
        functionConstants.setConstantValue(&property,
                                           type: .bool,
                                           index: 0)
        
        let vertexFunction = Renderer.library.makeFunction(name: vertexFunctionName)
        // 2가지 버전으로 함수를 컴파일 한다.
        // index 0의 함수 상수가 True인 버전과, False인 버전이다.
        // 더 많은 Texture가 포함된 경우 컴파일러는 더 많은 Shader를 빌드하여 Constance 함수의 가능한 모든 조합을 만든다.
        
        var fragmentFunctionName = "fragment_main"
        if (vertexFunctionName == "vertex_plane") {
            fragmentFunctionName = "fragment_plane"
        }
        
        let fragmentFrunction = try! Renderer.library.makeFunction(name: fragmentFunctionName,
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
}

private extension Material {
    init(material: MDLMaterial?) {
        self.init()
        if let baseColor = material?.property(with: .baseColor),
           baseColor.type == .float3 {
            self.baseColor = baseColor.float3Value
        }
        if let specular = material?.property(with: .specular),
           specular.type == .float3 {
            self.specularColor = specular.float3Value
        }
        if let shininess = material?.property(with: .specularExponent),
           shininess.type == .float {
            self.shininess = shininess.floatValue
        }
    }
}
