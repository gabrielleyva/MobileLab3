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
    var destX:CGFloat?
    
    override func didMove(to view: SKView) {
        prepareMotionManager()
        createSpaceship()
        createBackground()
        
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
                    self.destX = currentX! + CGFloat((data?.acceleration.x)! * 100)
                }
                    
                else if (data?.acceleration.x)! > 0.0 {
                    self.destX = currentX! + CGFloat((data?.acceleration.x)! * 100)
                }
                
            })
            
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
        self.addChild(node)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let action = SKAction.moveTo(x: destX!, duration: 1)
        self.spaceship?.run(action)
    }
}
