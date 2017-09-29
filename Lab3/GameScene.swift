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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Game Coliision categories
    let meteorCategory: UInt32 = 0x1 << 1
    let spaceshipCategory: UInt32 = 0x1 << 2
    
    //Game Nodes
    private var spaceship : SKSpriteNode?
    private var motionManager: CMMotionManager?
    private var bg1: SKSpriteNode?
    private var bg2: SKSpriteNode?
    private var label = SKLabelNode()
    private var bigLabel = SKLabelNode()
    
    //Game Variables
    var destX:CGFloat?
    var timer = Timer()
    var score = 0
    var hit = false
    var start = false
    var gameOver = false
    var multiplier = 1
    let userDefaults = UserDefaults()
    let MULTIPLIERKEY = "MULTIPLIER"
    let HIGHSCOREKEY = "HIGHSCORE"
    
    override func didMove(to view: SKView) {
        createBackground()
        createBoundries()
        prepareLabel()
        prepareBigLabel(text: "Tap To Start")
        
        //set screen bounds
        self.view?.bounds = CGRect(x: 0, y: 0, width: (self.view?.frame.size.width)!, height: (self.view?.frame.size.height)!)
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        self.physicsWorld.contactDelegate = self
        
    }
    
    fileprivate func createBoundries(){
        let bottomOffset = CGFloat(400.0);
        let newFrame = CGRect(x: 0.0, y: -bottomOffset, width: self.frame.size.width, height: self.frame.size.height + bottomOffset)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: newFrame)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
    }
    
    fileprivate func prepareMotionManager() {
        motionManager = CMMotionManager()
        destX = 0.0
        
        if motionManager?.isAccelerometerAvailable == true {
            motionManager?.startAccelerometerUpdates(to: OperationQueue.current!, withHandler:{
                data, error in
                
                let currentX = self.spaceship?.position.x
                if (data?.acceleration.x)! < 0.0 {
                    self.destX = currentX! + CGFloat((data?.acceleration.x)! * 900)
                }
                    
                else if (data?.acceleration.x)! > 0.0 {
                    self.destX = currentX! + CGFloat((data?.acceleration.x)! * 900)
                }
                
            })
            
        }
    }
    
    fileprivate func prepareBigLabel(text: String) {
        self.bigLabel = SKLabelNode(fontNamed: "Avenir-BlackOblique")
        self.bigLabel.color = .white
        self.bigLabel.text = text
        self.bigLabel.position = CGPoint(x: ((self.view?.frame.size.width)! / 2) - (self.label.frame.size.width), y: (self.view?.frame.size.height)! / 2 - (self.label.frame.size.height))
        self.bigLabel.zPosition = 1
        self.bigLabel.numberOfLines = 2
        self.bigLabel.lineBreakMode = .byWordWrapping
        self.bigLabel.fontSize = CGFloat(72)
        self.addChild(self.bigLabel)
    }
    
    fileprivate func prepareLabel() {
        //score label set up
        self.multiplier = self.userDefaults.integer(forKey: MULTIPLIERKEY)
        self.label = SKLabelNode(fontNamed: "Avenir-BlackOblique")
        self.label.color = .white
        self.label.text = "Score: 0 x\(self.multiplier)"
        self.label.position = CGPoint(x: (self.view?.frame.size.width)! - 120, y: (self.view?.frame.size.height)! - 55)
        self.label.zPosition = 1
        self.label.fontSize = CGFloat(42)
        self.addChild(self.label)
        
    }
    
    fileprivate func createMeteor() -> SKEmitterNode{
        if let particle = SKEmitterNode(fileNamed: "meteor.sks") {
            particle.position = CGPoint(x: (self.spaceship?.position.x)!, y: frame.size.height)
            particle.physicsBody = SKPhysicsBody(circleOfRadius: 5)
            particle.physicsBody?.usesPreciseCollisionDetection = true
            particle.physicsBody?.categoryBitMask = meteorCategory
            particle.physicsBody?.collisionBitMask = 0

            return particle
        }
        
        return SKEmitterNode()
    }
    
    fileprivate func createSpaceship() {
        let spaceTexture = SKTexture(image: #imageLiteral(resourceName: "Spaceship"))
        let node = SKSpriteNode(texture: spaceTexture)
        node.size = CGSize(width: 200, height: 200)
        node.position = CGPoint(x: ((self.view?.frame.size.width)! / 2) - 200, y: -(self.view?.frame.size.height)! + 225)
        node.zPosition = 1
        
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 100))
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.isDynamic = true
        node.physicsBody?.usesPreciseCollisionDetection = true
        node.physicsBody?.categoryBitMask = spaceshipCategory
        node.physicsBody?.contactTestBitMask = meteorCategory
        node.physicsBody?.allowsRotation = false
        
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
    
    fileprivate func scheduleMeteorShower(){
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(self.generateMeteors), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func generateMeteors() {
        
        if hit == false {
            let node = self.createMeteor()
            self.addChild(node)
        
            let wait = SKAction.wait(forDuration: 3)
            let complete = SKAction.run {
                node.removeFromParent()
                //score updated
                if (!self.gameOver){
                    self.score = self.score + (1*self.multiplier)
                    self.label.text = "Score: " + String(self.score)+" x\(self.multiplier)"
                }
            }
            
            node.run(SKAction.sequence([wait, complete]))
        }
        
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if start == true {
            let action = SKAction.moveTo(x: destX!, duration: 0.8)
            self.spaceship?.run(action)
            self.animateBackground()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if start == false {
            start = true
            hit = false
            gameOver = false
            self.bigLabel.removeFromParent()
            createSpaceship()
            prepareMotionManager()
            scheduleMeteorShower()
            self.label.text = "Score: 0 x\(self.multiplier)"
        }
    }
    
    //MARK CONTACT DELEGATE METHODS
    func didBegin(_ contact: SKPhysicsContact) {
        
        print("Contact")
        
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        // 2 Assign the two physics bodies so that the one with the lower category is always stored in firstBody
        if  contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        if firstBody.categoryBitMask == meteorCategory && secondBody.categoryBitMask == spaceshipCategory {
            start = false
            hit = true
            let last_score = score
            score = 0
            self.gameOver = true
            self.timer.invalidate()
            self.spaceship?.removeFromParent()
            self.prepareBigLabel(text: " Game Over!\nTap To Restart")
            let highscore = self.userDefaults.integer(forKey: HIGHSCOREKEY)
            if (last_score > highscore){
                self.userDefaults.set(last_score, forKey: HIGHSCOREKEY)
            }
        }

    }

}
