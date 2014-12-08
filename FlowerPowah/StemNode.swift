//
//  StemNode.swift
//  FlowerPowah
//
//  Created by Kj Drougge on 2014-12-08.
//  Copyright (c) 2014 kj. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class StemNode: SKNode {
    private let length: Int
    private var stemSegments: [SKNode] = []
    
    init(length: Int) {
        self.length = length
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder){
        length = aDecoder.decodeIntegerForKey("length")
        
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(length, forKey: "length")
        
        super.encodeWithCoder(aCoder)
    }
    
    func addToScene(scene: SKScene, x: CGFloat, y: CGFloat, hidden: Bool){
        
        scene.addChild(self)
        
        for i in 0..<length {
            let stemSegment = SKSpriteNode(imageNamed: StemTextureImage)
            let offset = stemSegment.size.width * CGFloat(i + 1)
            stemSegment.position = CGPointMake(x, y + offset) // scene.size.width/2, scene.size.height/3
            
            stemSegments.append(stemSegment)
            addChild(stemSegment)
            
            stemSegment.physicsBody = SKPhysicsBody(rectangleOfSize: stemSegment.size)
            stemSegment.physicsBody?.categoryBitMask = Category.Stem
            stemSegment.physicsBody?.collisionBitMask = Category.StemHolder
            stemSegment.physicsBody?.contactTestBitMask = Category.Flower
            
            stemSegment.hidden = hidden
            
            if i == 0{
                stemSegment.physicsBody?.dynamic = false
                stemSegment.physicsBody?.collisionBitMask = 0
            }
        }
        
        for i in 1...length-1 {
            let nodeA = stemSegments[i - 1]
            let nodeB = stemSegments[i]
            let joint = SKPhysicsJointPin.jointWithBodyA(nodeA.physicsBody, bodyB: nodeB.physicsBody, anchor: CGPointMake(CGRectGetMidX(nodeA.frame), CGRectGetMinY(nodeB.frame)))
            
            scene.physicsWorld.addJoint(joint)
        }
    }
    
    func attachToFlower(flower: SKSpriteNode){
        let lastNode = stemSegments.last!
        lastNode.position = CGPointMake(flower.position.x, flower.position.y + flower.size.height * 0.1)
        
        let joint = SKPhysicsJointPin.jointWithBodyA(lastNode.physicsBody, bodyB: flower.physicsBody, anchor: lastNode.position)
        
        flower.scene?.physicsWorld.addJoint(joint)
    }
}