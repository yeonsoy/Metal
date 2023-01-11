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
    
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        setupScene()
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
}
