//
//  Extensions.swift
//  MetalRenderer
//
//  Created by leesy on 2022/12/21.
//

import Foundation
import MetalKit

extension MTLVertexDescriptor {
    static func defaultVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
        
        return vertexDescriptor
    }
}

extension MDLVertexDescriptor {
    static func defaultVertexDescriptor() -> MDLVertexDescriptor {
        let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(.defaultVertexDescriptor())
        
        let attributePosition = vertexDescriptor.attributes[0] as! MDLVertexAttribute
        attributePosition.name = MDLVertexAttributePosition
        
        return vertexDescriptor
    }
}
