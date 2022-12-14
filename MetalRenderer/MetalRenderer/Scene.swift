//
//  Scene.swift
//  MetalRenderer
//
//  Created by leesy on 2023/01/11.
//

import Foundation

class Scene {
    var rootNode = Node()
    
    // Camera처럼 Geometry가 없는 Render되지 않는 Node를 구분하기 위해서 renderable을 사용.
    var renderables: [Renderable] = []
    
    var sceneSize: CGSize
    
    let camera = ArcballCamera()
    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        sceneSizeWillChange(to: sceneSize)
        setupScene()
    }
    
    func updateScene(deltaTime: Float) {
        // override this update the scene
    }
    
    final func update(deltaTime: Float) {
        updateScene(deltaTime: deltaTime)
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.viewMatrix = camera.viewMatrix
        fragmentUniforms.cameraPosition = camera.position
    }
    
    final func add(node: Node, parent: Node? = nil, render: Bool = true) {
        if let parent = parent {
            parent.add(childNode: node)
        } else {
            rootNode.add(childNode: node)
        }
        if render, let renderable = node as? Renderable {
            renderables.append(renderable)
        }
    }
    
    func setupScene() {
        // override this to add objects to the scene
    }
    
    func sceneSizeWillChange(to size: CGSize) {
        camera.aspect = Float(size.width / size.height)
        sceneSize = size
    }
}
