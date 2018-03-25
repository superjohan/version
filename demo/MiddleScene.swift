//
//  MiddleScene.swift
//  demo
//
//  Created by Johan Halin on 25/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import Foundation
import SceneKit

func createMiddleScene(camera: SCNNode, size: CGSize) -> SCNScene {
    let scene = SCNScene()
    scene.background.contents = UIColor.black

    camera.position = SCNVector3Make(0, 0, 50)
    camera.isPaused = true
    
    scene.rootNode.addChildNode(camera)

    configureLight(scene)
    
    let backgroundBox = SCNBox(width: 200, height: 200, length: 200, chamferRadius: 0)
    applyNoiseShader(object: backgroundBox, scale: 50, size: size)

    let backgroundBoxNode = SCNNode(geometry: backgroundBox)
    backgroundBoxNode.position = SCNVector3Make(0, 0, -100)
    
    scene.rootNode.addChildNode(backgroundBoxNode)

    let box = SCNBox(width: 20, height: 20, length: 20, chamferRadius: 0)
    box.firstMaterial?.diffuse.contents = UIColor.init(white: 0, alpha: 0.5)

    let boxNode = SCNNode(geometry: box)
    boxNode.position = SCNVector3Make(0, 0, 0)

    boxNode.runAction(
        SCNAction.repeatForever(
            SCNAction.rotateBy(
                x: 0,
                y: CGFloat.pi * 2,
                z: 0,
                duration: 5
            )
        )
    )

    scene.rootNode.addChildNode(boxNode)

    return scene
}

fileprivate func configureLight(_ scene: SCNScene) {
    let lightNode = SCNNode()
    lightNode.light = SCNLight()
    lightNode.light?.type = SCNLight.LightType.omni
    lightNode.light?.color = UIColor(white: 1.0, alpha: 1.0)
    lightNode.position = SCNVector3Make(0, 0, 50)
    scene.rootNode.addChildNode(lightNode)
}

fileprivate func applyNoiseShader(object: SCNGeometry, scale: Float, size: CGSize) {
    do {
        object.firstMaterial?.shaderModifiers = [
            SCNShaderModifierEntryPoint.fragment: try String(contentsOfFile: Bundle.main.path(forResource: "noise.shader", ofType: "fragment")!, encoding: String.Encoding.utf8)
        ]
    } catch {}
    
    object.firstMaterial?.setValue(CGPoint(x: size.width, y: size.width), forKey: "resolution")
    object.firstMaterial?.setValue(scale, forKey: "scale")
}

