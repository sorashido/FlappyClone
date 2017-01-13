//
//  GameScene.swift
//  FlappyClone
//
//  Created by tela on 2016/11/05.
//  Copyright © 2016 tela. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory{
    static let witch : UInt32 = 0x1 << 1
    static let ground : UInt32 = 0x1 << 2
    static let wall : UInt32 = 0x1 << 3
    static let score :UInt32 = 0x1 << 4
}

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var ground = SKSpriteNode(imageNamed: "ground")
    var witch = SKSpriteNode(imageNamed: "girl")
    
    var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    
    var tapLocation = CGPoint()
    
    var score = 0
    let scoreLbl = SKLabelNode()
    
    var died = false
    var restartBTN = SKSpriteNode()
    
    func resetartScene(){
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene(){
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<4 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.name = "background"
            background.position = CGPoint.init(x: CGFloat(i) * background.size.width, y: 0)
            self.addChild(background)
        }
        
        /* Setup your scene here*/
        scoreLbl.position = CGPoint(x: 0, y: self.frame.height/2.5)
        scoreLbl.text = "\(score)"
        scoreLbl.fontSize = 80
        scoreLbl.fontName = "04b_19"
        scoreLbl.zPosition = 5
        self.addChild(scoreLbl)
        
        ground.position = CGPoint(x:0, y:-self.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.witch
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.witch
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        ground.zPosition = 3
        self.addChild(ground)
        
        witch = SKSpriteNode(imageNamed: "girl")
        witch.position = CGPoint(x:0 - witch.frame.width, y:0)
        witch.physicsBody = SKPhysicsBody(circleOfRadius:witch.frame.height/2)
        witch.physicsBody?.categoryBitMask = PhysicsCategory.witch
        witch.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall
        witch.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.wall | PhysicsCategory.score
        witch.physicsBody?.affectedByGravity = false
        witch.physicsBody?.isDynamic = true
        witch.zPosition = 2
        self.addChild(witch)
    }
    
    override func didMove(to view: SKView) {
        createScene()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.score && secondBody.categoryBitMask == PhysicsCategory.witch{
            score += 1
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
            
        if firstBody.categoryBitMask == PhysicsCategory.witch && secondBody.categoryBitMask == PhysicsCategory.score{
            score += 1
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        }
    }
    
    func createBTN(){
        restartBTN = SKSpriteNode(imageNamed: "restart")
        restartBTN.size = CGSize(width: 150, height: 75)
//        restartBTN = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 250, height: 150))
        restartBTN.position = CGPoint(x: 0, y: 0)
        restartBTN.zPosition = 6
        self.addChild(restartBTN)
        
//        restartBTN.run(SKAction.scale(to: 1.0, duration: 0.3))
        restartBTN.run(SKAction.scale(to: 2.0, duration: 0.3))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        if gameStarted == false{
            gameStarted = true

            let spawn = SKAction.run({
                () in
                self.createWalls()
            })

            let delay = SKAction.wait(forDuration: 1.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.move(by: CGVector(dx:-distance * 4,dy: 0), duration: TimeInterval(distance * 0.01))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])

            //
            let touch = touches.first
            tapLocation = touch!.location(in: self.view)
            if tapLocation.y > self.frame.height/4{
                witch.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                witch.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 500))
            }else{
                witch.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                witch.physicsBody?.applyImpulse(CGVector(dx: 50, dy: -400))
            }
            witch.physicsBody?.affectedByGravity = true
        }else{
            //game started ==true
            if died == true{
                
            }else{
                let touch = touches.first
                tapLocation = touch!.location(in: self.view)
            
                if tapLocation.y > self.frame.height/4{
                    witch.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    witch.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 500))
                }else{
                    witch.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    witch.physicsBody?.applyImpulse(CGVector(dx: 50, dy: -400))
                }
            }
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if died == true{
                if restartBTN.contains(location){
                    resetartScene()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    func createWalls(){
        
//        let scoreNode = SKSpriteNode()
        let letterName=CGFloat.random() < 0.2 ? "letter1":"letter2";
        let scoreNode = SKSpriteNode(imageNamed: letterName)
        scoreNode.size  = CGSize(width: 70, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width/2 - wallPair.frame.width, y:  -wallPair.frame.height)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.witch
//        scoreNode.color = SKColor.blue
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "wall")
        let btmWall = SKSpriteNode(imageNamed: "wall")
        
        topWall.position = CGPoint(x:self.frame.width/2 - wallPair.frame.width, y:self.frame.height/2)
        btmWall.position = CGPoint(x:self.frame.width/2 - wallPair.frame.width, y:-self.frame.height/2)
        
        topWall.xScale*=0.6
        btmWall.xScale*=0.6
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.witch
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.witch
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false

        btmWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.witch
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.witch
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        wallPair.addChild(scoreNode)

        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -self.frame.height/2+200, max: self.frame.height/2-200)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.run(moveAndRemove)
        
        self.addChild(wallPair)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        if gameStarted == true{
            if died == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node,error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x: bg.position.x+bg.size.width*2, y: bg.position.y)
                    }
                }))
            }
        }
        
        //
        if(witch.position.x < -self.frame.width/2){
            
            if died == false{
                createBTN()
                died = true
            }
            
            enumerateChildNodes(withName:"wallPair", using: ({
               (node,error) in
                node.speed = 0
                
                self.removeAllActions()
            }))
        }
    }
}
