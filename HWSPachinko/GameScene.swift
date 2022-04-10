//
//  GameScene.swift
//  HWSPachinko
//
//  Created by Johan Forsell on 2022-04-10.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var ballColors = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    
    var ballsInPlayLabel: SKLabelNode!
    
    var ballsInPlay = 0 {
        didSet {
            ballsInPlayLabel.text = "Balls left: \(5 - ballsInPlay)"
            if ballsInPlay > 4 {
                retryButton.isHidden = false
            } else {
                retryButton.isHidden = true
            }
        }
    }
    
    var retryButton: SKLabelNode!
    
    var homeButton: SKButtonNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
        
        homeButton = SKButtonNode(imageNamed: "hwslogowithtext", title: nil, action: {
            let url = URL(string: "hwsuikit://")!
            UIApplication.shared.open(url, options: [:]) { success in
                //
            }
        })
        homeButton.size = CGSize(width: 80, height: 64)
        homeButton.position = CGPoint(x: 60, y: 700)
        addChild(homeButton)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 140, y: 700)
        addChild(editLabel)
        
        ballsInPlayLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsInPlayLabel.text = "Balls left: 5"
        ballsInPlayLabel.horizontalAlignmentMode = .right
        ballsInPlayLabel.position = CGPoint(x: 980, y: 660)
        addChild(ballsInPlayLabel)
        
        retryButton = SKLabelNode(fontNamed: "Chalkduster")
        retryButton.text = "Try again"
        retryButton.horizontalAlignmentMode = .right
        retryButton.position = CGPoint(x: 980, y: 620)
        retryButton.isHidden = true
        addChild(retryButton)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else if objects.contains(retryButton) && retryButton.isHidden == false {
            ballsInPlay = 0
        } else if objects.contains(homeButton) {
            let url = URL(string: "hwsuikit://")!
            UIApplication.shared.open(url, options: [:]) { success in
                //
            }
        } else {
            if editingMode {
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.name = "pin"
                addChild(box)
            } else {
                if ballsInPlay < 5 {
                    let ball = SKSpriteNode(imageNamed: ballColors.randomElement()!)
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
                    ball.physicsBody?.restitution = 0.4
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                    ball.position = CGPoint(x: location.x, y: 700)
                    ball.name = "ball"
                    addChild(ball)
                    ballsInPlay += 1
                }
            }
        }
    }
    
    private func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    private func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        slotGlow.zPosition = -1
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    private func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballsInPlay -= 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        } else if object.name == "pin" {
            destroy(pin: object)
        }
    }
    
    private func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    private func destroy(pin: SKNode) {
        pin.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
}
