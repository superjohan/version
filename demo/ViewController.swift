//
//  ViewController.swift
//  demo
//
//  Created by Johan Halin on 12/03/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import UIKit
import AVFoundation
import SceneKit
import Foundation
import GameplayKit

class ViewController: UIViewController, SCNSceneRendererDelegate {
    let audioPlayer: AVAudioPlayer
    let sceneView = SCNView()
    let camera = SCNNode()
    let startButton: UIButton
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)
    let brandViewContainer = BrandViewContainerView(frame: .zero)
    let brandOrder: [Int]

    var isInMiddleState = false
    var middleCount = 0
    var middleStart: TimeInterval = -1
    var brandPosition = 0
    
    // MARK: - UIViewController
    
    init() {
        if let trackUrl = Bundle.main.url(forResource: "audio", withExtension: "mp3") {
            guard let audioPlayer = try? AVAudioPlayer(contentsOf: trackUrl) else {
                abort()
            }
            
            self.audioPlayer = audioPlayer
        } else {
            abort()
        }
        
        let camera = SCNCamera()
        camera.zFar = 600
        camera.vignettingIntensity = 1
        camera.vignettingPower = 1
        camera.colorFringeStrength = 3
        camera.bloomIntensity = 1
        camera.bloomBlurRadius = 20
        camera.wantsHDR = true
        self.camera.camera = camera // lol
        
        let startButtonText =
            "\"version\"\n" +
                "by dekadence\n" +
                "\n" +
                "programming, music, and graphics by ricky martin\n" +
                "graphics by jaakko\n" +
                "\n" +
                "presented at revision 2018\n" +
                "\n" +
        "tap anywhere to start"
        self.startButton = UIButton.init(type: UIButtonType.custom)
        self.startButton.setTitle(startButtonText, for: UIControlState.normal)
        self.startButton.titleLabel?.numberOfLines = 0
        self.startButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.startButton.backgroundColor = UIColor.black
        
        var brandOrder: [Int] = []
        for i in 0..<32 {
            brandOrder.append(i)
        }
        
        self.brandOrder = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: brandOrder) as! [Int]
        
        super.init(nibName: nil, bundle: nil)
        
        self.startButton.addTarget(self, action: #selector(startButtonTouched), for: UIControlEvents.touchUpInside)
        
        self.view.backgroundColor = .black
        self.sceneView.backgroundColor = .black
        self.sceneView.delegate = self
        
        self.qtFoolingBgView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // barely visible tiny view for fooling Quicktime player. completely black images are ignored by QT
        self.view.addSubview(self.qtFoolingBgView)
        
        self.view.addSubview(self.sceneView)
        self.view.addSubview(self.brandViewContainer)
        
        self.view.addSubview(self.startButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audioPlayer.prepareToPlay()
        
        self.sceneView.scene = createScene()
    }
    
    let testView1 = UIView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.qtFoolingBgView.frame = CGRect(
            x: (self.view.bounds.size.width / 2) - 1,
            y: (self.view.bounds.size.height / 2) - 1,
            width: 2,
            height: 2
        )
        
        self.sceneView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        self.sceneView.isPlaying = true
        self.sceneView.isHidden = true
        
        self.brandViewContainer.frame = self.view.bounds
        self.brandViewContainer.isHidden = true
        self.brandViewContainer.adjustFrames()
        
        self.startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        
        self.view.addSubview(self.testView1)
        
        self.testView1.frame = self.view.bounds
        self.testView1.backgroundColor = .red
        self.testView1.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.audioPlayer.stop()
    }

    // MARK: - SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // this function is run in a background thread.
        DispatchQueue.main.async {
            if self.isInMiddleState {
                // note for the future: if quicktime can handle this updating every frame, then do that instead
                
                if self.middleStart < 0 {
                    self.middleStart = time
                    self.showNextBrand()
                }
                
                let delta = time - self.middleStart
                
                if delta > 0.033333 {
                    self.middleStart = -1
                }
            }
        }
    }
    
    // MARK: - Private
    
    @objc
    fileprivate func startButtonTouched(button: UIButton) {
        self.startButton.isUserInteractionEnabled = false
        
        // long fadeout to ensure that the home indicator is gone
        UIView.animate(withDuration: 4, animations: {
            self.startButton.alpha = 0
        }, completion: { _ in
            self.start()
        })
    }
    
    fileprivate func start() {
        self.startButton.isHidden = true
        self.sceneView.isHidden = true
        
        self.audioPlayer.play()
        
        scheduleEvents()
    }
    
    fileprivate func scheduleEvents() {
        let beatLength = Constants.beatLength
        let barLength = Constants.barLength
        
        func scheduleBeatEvents(position: Double) {
            perform(#selector(showFirstBeatState), with: nil, afterDelay: position)
            perform(#selector(showSecondBeatState), with: nil, afterDelay: position + beatLength)
            perform(#selector(showThirdBeatState), with: nil, afterDelay: position + (beatLength * 2.0))
        }
        
        for i in 0..<37 {
            let position = Double(i) * barLength
            
            if i >= 0 && i < 16 {
                scheduleBeatEvents(position: position)
            }
            
            if i == 16 {
                perform(#selector(showMiddleState), with: nil, afterDelay: position)
            }
            
            if i >= 20 && i < 36 {
                scheduleBeatEvents(position: position)
            }
            
            if i == 36 {
                perform(#selector(endItAll), with: nil, afterDelay: position)
            }
        }
    }
    
    @objc
    fileprivate func showFirstBeatState() {
        self.testView1.isHidden = false
        self.sceneView.isHidden = true
        self.brandViewContainer.isHidden = true
        self.isInMiddleState = false

        self.camera.isPaused = true
    }
    
    @objc
    fileprivate func showSecondBeatState() {
        self.testView1.isHidden = true
        self.sceneView.isHidden = false
        self.brandViewContainer.isHidden = true
        self.isInMiddleState = false

        self.camera.isPaused = false
    }
    
    @objc
    fileprivate func showThirdBeatState() {
        self.testView1.isHidden = true
        self.sceneView.isHidden = true
        self.brandViewContainer.isHidden = false
        self.isInMiddleState = false

        self.camera.isPaused = true

        self.brandViewContainer.showBrand(self.brandOrder[self.brandPosition], animated: true)
        
        self.brandPosition += 1
    }
    
    @objc
    fileprivate func showMiddleState() {
        self.testView1.isHidden = true
        self.sceneView.isHidden = true
        self.brandViewContainer.isHidden = false
        self.isInMiddleState = true
    }
    
    @objc
    fileprivate func endItAll() {
        self.testView1.isHidden = true
        self.sceneView.isHidden = true
        self.brandViewContainer.isHidden = true
        self.isInMiddleState = false
    }
    
    fileprivate func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black
        
        self.camera.position = SCNVector3Make(-50, 60, 100)
        self.camera.rotation = SCNVector4Make(1, 1, 0, -0.4)
        let duration: TimeInterval = Constants.beatLength * 32
        
        let cameraMoveAction = SCNAction.move(to: SCNVector3Make(-40, 10, 0), duration: duration)
        cameraMoveAction.timingMode = SCNActionTimingMode.easeInEaseOut
        self.camera.runAction(cameraMoveAction)
        
        let cameraRotateAction = SCNAction.rotateBy(x: 0.4, y: -1.3, z: 0, duration: duration)
        cameraRotateAction.timingMode = cameraMoveAction.timingMode
        self.camera.runAction(cameraRotateAction)

        self.camera.isPaused = true // pause immediately. gotta wait for the demo to start
        
        scene.rootNode.addChildNode(self.camera)
        
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
    
    fileprivate func showNextBrand() {
        self.brandViewContainer.showBrand(self.middleCount, animated: false)
        
        self.middleCount += 1
        
        if self.middleCount >= 32 {
            self.middleCount = 0
        }
    }
}
