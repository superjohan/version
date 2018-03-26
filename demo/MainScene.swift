//
//  MainScene.swift
//  demo
//
//  Created by Johan Halin on 25/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import Foundation
import SceneKit

func createMainSceneCamera() -> SCNCamera {
    let camera = SCNCamera()
    camera.zFar = 600
    camera.vignettingIntensity = 1
    camera.vignettingPower = 1
    camera.colorFringeStrength = 3
    camera.bloomIntensity = 0.5
    camera.bloomBlurRadius = 20
    camera.wantsHDR = true
    
    return camera
}

func createMainScene(camera: SCNNode) -> SCNScene {
    let scene = SCNScene()
    scene.background.contents = UIColor.init(white: 0.42, alpha: 1)
    
    camera.position = SCNVector3Make(-30, 50, 60)
    camera.rotation = SCNVector4Make(1.5, 1, 0, -0.4)
    let duration: TimeInterval = Constants.beatLength * 32
    
    let cameraMoveAction = SCNAction.move(to: SCNVector3Make(-70, 30, 0), duration: duration)
    cameraMoveAction.timingMode = SCNActionTimingMode.easeInEaseOut
    camera.runAction(cameraMoveAction)
    
    let cameraRotateAction = SCNAction.rotateBy(x: 0.1, y: -1.3, z: 0, duration: duration)
    cameraRotateAction.timingMode = cameraMoveAction.timingMode
    camera.runAction(cameraRotateAction)
    
    camera.isPaused = true // pause immediately. gotta wait for the demo to start
    
    scene.rootNode.addChildNode(camera)
    
    configureLight(scene)
    
    let factory = loadModel(name: "tehdas", textureName: nil, color: UIColor.init(white: 0.8, alpha: 1.0))
    factory.scale = SCNVector3Make(3, 3, 3)
    factory.pivot = SCNMatrix4MakeTranslation(8, 0, 0)
    scene.rootNode.addChildNode(factory)
    
    let box2 = SCNBox(width: 200, height: 100, length: 200, chamferRadius: 0)
    box2.firstMaterial?.diffuse.contents = UIColor.gray
    
    let boxNode2 = SCNNode(geometry: box2)
    boxNode2.position = SCNVector3Make(0, -51, 0)
    
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
    directionalLightNode.position = SCNVector3Make(-10, 20, 40)
    directionalLightNode.rotation = SCNVector4Make(1, -0.2, 0, -0.75)
    scene.rootNode.addChildNode(directionalLightNode)
    
    let omniLightNode = SCNNode()
    omniLightNode.light = SCNLight()
    omniLightNode.light?.type = SCNLight.LightType.ambient
    omniLightNode.light?.color = UIColor(white: 0.1, alpha: 1.0)
    scene.rootNode.addChildNode(omniLightNode)
}
