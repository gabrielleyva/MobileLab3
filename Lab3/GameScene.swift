//
//  GameScene.swift
//  Lab3
//
//  Created by Gabriel I Leyva Merino on 9/24/17.
//  Copyright © 2017 Leyva_Phadate. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    private var spaceship : SKSpriteNode?
    private var motionManager: CMMotionManager?
    private var bg1: SKSpriteNode?
    private var bg2: SKSpriteNode?
    var destX:CGFloat?
    
    override func didMove(to view: SKView) {
        prepareMotionManager()
        createSpaceship()
        createBackground()
        createMeteor()
        
        //set screen bounds
        self.view?.bounds = CGRect(x: 0, y: 0, width: (self.view?.frame.size.width)!, height: (self.view?.frame.size.height)!)
        
    }
    
    fileprivate func prepareMotionManager() {
        motionManager = CMMotionManager()
        destX = 0.0
        
        if motionManager?.isAccelerometerAvailable == true {
            // 2
            motionManager?.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:{
                data, error in
                
                let currentX = self.spaceship?.position.x
                
                // 3
                if (data?.acceleration.x)! < 0.0 {
                    self.destX = currentX! + CGFloat((data?.acceleration.x)! * 900)
                }
                    
                else if (data?.acceleration.x)! > 0.0 {
                    self.destX = currentX! + CGFloat((data?.acceleration.x)! * 900)
                }
                
            })
            
        }
    }
    
    fileprivate func createMeteor() {
        if let particles = SKEmitterNode(fileNamed: "meteor.sks") {
            particles.position = CGPoint(x: 150, y: 250)
            addChild(particles)
        }
    }
    
    fileprivate func createSpaceship() {
        let spaceTexture = SKTexture(image: #imageLiteral(resourceName: "Spaceship"))
        let node = SKSpriteNode(texture: spaceTexture)
        node.size = CGSize(width: 200, height: 200)
        node.position = CGPoint(x: ((self.view?.frame.size.width)! / 2) - 200, y: -(self.view?.frame.size.height)! + 225)
        node.zPosition = 1
        self.spaceship = node
        self.addChild(self.spaceship!)
    }
    
    fileprivate func createBackground() {
        let spaceTexture = SKTexture(image: #imageLiteral(resourceName: "SpaceBackground"))
        
        let node = SKSpriteNode(texture: spaceTexture)
        node.size = CGSize(width: frame.size.width, height: frame.size.height)
        node.position = CGPoint(x: 0, y: 0)
        node.zPosition = 0
        self.bg1 = node
        self.addChild(self.bg1!)
        
        let node2 = SKSpriteNode(texture: spaceTexture)
        node2.size = CGSize(width: frame.size.width, height: frame.size.height)
        node2.position = CGPoint(x: 0, y: (self.bg1?.size.height)! - 1)
        node2.zPosition = 0
        self.bg2 = node2
        self.addChild(self.bg2!)
    }
    
    fileprivate func animateBackground() {
        self.bg1?.position = CGPoint(x: (self.bg1?.position.x)!, y: (self.bg1?.position.y)! - 4)
        self.bg2?.position = CGPoint(x: (self.bg2?.position.x)!, y: (self.bg2?.position.y)! - 4)
        
        if (self.bg1?.position.y)! < -(self.bg1?.size.height)! {
            self.bg1?.position = CGPoint(x: (self.bg1?.position.x)!, y: (self.bg2?.position.y)! + (self.bg2?.size.height)!)
        }
        
        if (self.bg2?.position.y)! < -(self.bg2?.size.height)! {
            self.bg2?.position = CGPoint(x: (self.bg2?.position.x)!, y: (self.bg1?.position.y)! + (self.bg1?.size.height)!)
        }
    }
    
    

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let action = SKAction.moveTo(x: destX!, duration: 1)
        self.spaceship?.run(action)
        self.animateBackground()
    }
}
