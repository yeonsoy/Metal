//
//  ViewController.swift
//  MetalRenderer
//
//  Created by Seungyeon Lee on 2022/12/05.
//

import Cocoa
import MetalKit

class ViewController: NSViewController {
    
    @IBOutlet var metalView: MTKView!
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        renderer = Renderer(view: metalView)
        metalView.device = Renderer.device
        metalView.delegate = renderer
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
    }
}

