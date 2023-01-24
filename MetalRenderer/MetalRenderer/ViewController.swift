//
//  ViewController.swift
//  MetalRenderer
//
//  Created by leesy on 2022/12/08.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    
    @IBOutlet var metalView: MTKView!
    var renderer: Renderer?
    var scene: Scene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderer = Renderer(view: metalView)
        metalView.device = Renderer.device
        metalView.delegate = renderer
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        scene = RayBreak(sceneSize: metalView.bounds.size)
        renderer?.scene = scene
        
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(pan)
    }
    
    override func scrollWheel(with event: NSEvent) {
        scene?.camera.zoom(delta: Float(event.deltaY))
    }
    
    @objc func handlePan(gesture: NSPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let delta = SIMD2<Float>(Float(translation.x),
                                 Float(translation.y))
        
        scene?.camera.rotate(delta: delta)
        gesture.setTranslation(.zero, in: gesture.view)
    }
    
}
