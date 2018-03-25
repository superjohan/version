//
//  MainScene.swift
//  demo
//
//  Created by Johan Halin on 25/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import Foundation
import SceneKit

func createMainScene(camera: SCNNode) -> SCNScene {
    let scene = SCNScene()
    scene.background.contents = UIColor.black
    
    camera.position = SCNVector3Make(-50, 60, 100)
    camera.rotation = SCNVector4Make(1, 1, 0, -0.4)
    let duration: TimeInterval = Constants.beatLength * 32
    
    let cameraMoveAction = SCNAction.move(to: SCNVector3Make(-40, 10, 0), duration: duration)
    cameraMoveAction.timingMode = SCNActionTimingMode.easeInEaseOut
    camera.runAction(cameraMoveAction)
    
    let cameraRotateAction = SCNAction.rotateBy(x: 0.4, y: -1.3, z: 0, duration: duration)
    cameraRotateAction.timingMode = cameraMoveAction.timingMode
    camera.runAction(cameraRotateAction)
    
    camera.isPaused = true // pause immediately. gotta wait for the demo to start
    
    scene.rootNode.addChildNode(camera)
    
    configureLight(scene)
    
    let box = SCNBox(width: 20, height: 20, length: 20, chamferRadius: 0)
    box.firstMaterial?.diffuse.contents = UIColor.white
    
    let boxNode = SCNNode(geometry: box)
    boxNode.position = SCNVector3Make(0, 20, 0)
    
    boxNode.runAction(
        SCNAction.repeatForever(
            SCNAction.rotateBy(
                x: CGFloat(-10 + Int(arc4random_uniform(20))),
                y: CGFloat(-10 + Int(arc4random_uniform(20))),
                z: CGFloat(-10 + Int(arc4random_uniform(20))),
                duration: TimeInterval(8 + arc4random_uniform(5))
            )
        )
    )
    
    scene.rootNode.addChildNode(boxNode)
    
    let box2 = SCNBox(width: 20, height: 100, length: 20, chamferRadius: 0)
    box2.firstMaterial?.diffuse.contents = UIColor.gray
    
    let boxNode2 = SCNNode(geometry: box2)
    boxNode2.position = SCNVector3Make(0, -50, 0)
    
    scene.rootNode.addChildNode(boxNode2)
    
    return scene
}

fileprivate func configureLight(_ scene: SCNScene) {
    let directionalLightNode = SCNNode()
    directionalLightNode.light = SCNLight()
    directionalLightNode.light?.type = SCNLight.LightType.directional
    directionalLightNode.light?.castsShadow = true
    directionalLightNode.light?.shadowRadius = 30
    directionalLightNode.light?.shadowColor = UIColor(white: 0, alpha: 0.75)
    directionalLightNode.light?.color = UIColor(white: 1.0, alpha: 1.0)
    directionalLightNode.position = SCNVector3Make(0, 20, 40)
    directionalLightNode.rotation = SCNVector4Make(1, 0, 0, -0.75)
    scene.rootNode.addChildNode(directionalLightNode)
    
    let omniLightNode = SCNNode()
    omniLightNode.light = SCNLight()
    omniLightNode.light?.type = SCNLight.LightType.ambient
    omniLightNode.light?.color = UIColor(white: 0.1, alpha: 1.0)
    scene.rootNode.addChildNode(omniLightNode)
}
