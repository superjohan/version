//
//  SceneKitUtils.swift
//  demo
//
//  Created by Johan Halin on 25/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import Foundation
import SceneKit

func loadModel(name: String, textureName: String?) -> SCNNode {
    guard let filePath = Bundle.main.path(forResource: name, ofType: "dae", inDirectory: "") else { abort() }
    let referenceURL = URL(fileURLWithPath: filePath)
    guard let referenceNode = SCNReferenceNode(url: referenceURL) else { abort() }
    referenceNode.load()
    
    if let textureName = textureName {
        let boatImage: UIImage? = UIImage(named: textureName)
        let childNodes = referenceNode.childNodes
        for childNode in childNodes {
            childNode.geometry?.firstMaterial = SCNMaterial()
            childNode.geometry?.firstMaterial?.diffuse.contents = boatImage
        }
    }
    
    return referenceNode
}
