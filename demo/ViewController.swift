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

class ViewController: UIViewController, SCNSceneRendererDelegate {
    let audioPlayer: AVAudioPlayer
    let sceneView = SCNView()
    let camera = SCNNode()
    let startButton: UIButton
    let qtFoolingBgView: UIView = UIView.init(frame: CGRect.zero)

    let brandViewContainer = BrandViewContainerView(frame: .zero)
    
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
//        camera.vignettingIntensity = 1
//        camera.vignettingPower = 1
//        camera.colorFringeStrength = 3
//        camera.bloomIntensity = 1
//        camera.bloomBlurRadius = 40
        self.camera.camera = camera // lol
        
        let startButtonText =
            "\"version\"\n" +
                "by dekadence\n" +
                "\n" +
                "programming, music, and graphics by ricky martin\n" +
                "\n" +
                "presented at revision 2018\n" +
                "\n" +
        "tap anywhere to start"
        self.startButton = UIButton.init(type: UIButtonType.custom)
        self.startButton.setTitle(startButtonText, for: UIControlState.normal)
        self.startButton.titleLabel?.numberOfLines = 0
        self.startButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.startButton.backgroundColor = UIColor.black
        
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
    let testView2 = UIView()
    let testView4 = UIView()

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
        self.view.addSubview(self.testView2)
        self.view.addSubview(self.testView4)
        
        self.testView1.frame = self.view.bounds
        self.testView2.frame = self.view.bounds
        self.testView4.frame = self.view.bounds
        
        self.testView1.backgroundColor = .red
        self.testView2.backgroundColor = .green
        self.testView4.backgroundColor = .yellow

        self.testView1.isHidden = true
        self.testView2.isHidden = true
        self.testView4.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.audioPlayer.stop()
    }
    
    // MARK: - SCNSceneRendererDelegate

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // this function is run in a background thread.
//        DispatchQueue.main.async {
//        }
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
        self.sceneView.isHidden = false
        
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
            let position = Double(i) * barLength;
            
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
        self.testView2.isHidden = true
        self.brandViewContainer.isHidden = true
        self.testView4.isHidden = true
    }
    
    @objc
    fileprivate func showSecondBeatState() {
        self.testView1.isHidden = true
        self.testView2.isHidden = false
        self.brandViewContainer.isHidden = true
        self.testView4.isHidden = true
    }
    
    @objc
    fileprivate func showThirdBeatState() {
        self.testView1.isHidden = true
        self.testView2.isHidden = true
        self.brandViewContainer.isHidden = false
        self.testView4.isHidden = true

        self.brandViewContainer.showBrand(Int(arc4random_uniform(15)), animated: false)
    }
    
    @objc
    fileprivate func showMiddleState() {
        self.testView1.isHidden = true
        self.testView2.isHidden = true
        self.brandViewContainer.isHidden = true
        self.testView4.isHidden = false
    }
    
    @objc
    fileprivate func endItAll() {
        self.testView1.isHidden = true
        self.testView2.isHidden = true
        self.brandViewContainer.isHidden = true
        self.testView4.isHidden = true
    }
    
    fileprivate func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.black
        
        self.camera.position = SCNVector3Make(0, 0, 58)
        
        scene.rootNode.addChildNode(self.camera)
        
        configureLight(scene)
        
        return scene
    }
    
    fileprivate func configureLight(_ scene: SCNScene) {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = SCNLight.LightType.omni
        omniLightNode.light?.color = UIColor(white: 1.0, alpha: 1.0)
        omniLightNode.position = SCNVector3Make(0, 0, 60)
        scene.rootNode.addChildNode(omniLightNode)
    }
}
