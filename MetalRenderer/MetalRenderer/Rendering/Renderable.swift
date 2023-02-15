//
//  Renderable.swift
//  MetalRenderer
//
//  Created by leesy on 2023/01/11.
//

import Foundation
import MetalKit

protocol Renderable {
    var name: String { get }
    func render(commandEncoder: MTLRenderCommandEncoder,
                uniforms vertex: Uniforms,
                fragmentUniforms fragment: FragmentUniforms,
                deltaTime: Float)
}
