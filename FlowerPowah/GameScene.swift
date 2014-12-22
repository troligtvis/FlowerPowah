//
//  GameScene.swift
//  FlowerPowah
//
//  Created by Kj Drougge on 2014-12-07.
//  Copyright (c) 2014 kj. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let manager = CMMotionManager()
    let motionQueue = NSOperationQueue()
    
    var flower: SKSpriteNode!
    var leaves: [SKSpriteNode]! = []
    
    var offsets: [Int]! = []
    var hasLeaves: Bool! = true

    
    // Shake
    var lastX: Double = 0.0;
    var lastY: Double = 0.0;
    var lastZ: Double = 0.0;
    
    var values:[Double] = [];

    
    func shakeFound() {
        println("Shake shake")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        if manager.accelerometerAvailable{
           manager.accelerometerUpdateInterval = 1/10
            manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler:
                {(data: CMAccelerometerData!, error: NSError!) in
                
                    var value = abs(data.acceleration.x + data.acceleration.y + data.acceleration.z - self.lastX - self.lastY - self.lastZ)
                    
                    self.values.append(value)
                    
                    if( self.values.count >= 20){
                        self.values.removeAtIndex(0)
                    }
                    
                    var sum = self.values.reduce(0, combine: +)
        
                    //println("Sum is \(sum)");
                    
                    if(sum/20 > Double(3.5)){
                        dispatch_async(dispatch_get_main_queue(), {
                            self.flower.texture = SKTexture(imageNamed: Flower2TextureImage)
                            self.flower.setScale(0.25)
                            self.fallingLeaves()
                        });
                        
                        sum = 0;
                        self.values.removeAll(keepCapacity: true);
                    }
                    
                    self.lastX = data.acceleration.x;
                    self.lastY = data.acceleration.y;
                    self.lastZ = data.acceleration.z;
            })
            
            manager.startDeviceMotionUpdatesToQueue(motionQueue, withHandler: gravityUpdated)
        } else {
            println("Accelerometer is not available")
        }

        setUpPhysics()
        setUpBackground()
        
        setUpFlower()
        setUpLeaves()
        
        setUpStem()
    }
    
    private func setUpPhysics() {
        physicsWorld.gravity = CGVectorMake(0.0, 9.8)
        physicsWorld.speed = 1.0
    }
    
    private func setUpLeaves(){
        for var i = 0; i < 5; ++i{
            var leaf = SKSpriteNode(imageNamed: LeafTextureImage)
            
            leaf.zPosition = Layer.Leaf
            leaf.setScale(0.5)
            
            leaf.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: LeafTextureImage), size: leaf.size)
            leaf.physicsBody?.affectedByGravity = false
            leaf.physicsBody?.allowsRotation = true
            leaf.physicsBody?.categoryBitMask = Category.Leaf
            leaf.physicsBody?.collisionBitMask = 0
            leaf.physicsBody?.contactTestBitMask = Category.Stem
            
            leaf.hidden = true
            
            addChild(leaf)
            leaves.append(leaf)
        }
        
        hasLeaves = true

    }
    
    func fallingLeaves(){
        if hasLeaves.boolValue{
            for var i = 0; i < leaves.count; ++i{
                var offset = i * 100
                offsets.append(offset)
                fallingLeaf(i)
            }
            hasLeaves = false
        }
    }
    
    private func fallingLeaf(i: Int){
        leaves[i].hidden = false
        leaves[i].position = CGPointMake(CGRectGetMidX(flower.frame) , CGRectGetMidY(flower.frame))
        
        var fallingLeafAction = SKAction.moveTo(CGPoint(x: 300 + offsets[i], y: 100), duration: 2.0)
        leaves[i].runAction(fallingLeafAction, completion: {
            self.leaves[i].removeFromParent()
        })
    }
    
    private func setUpFlower() {
        flower = SKSpriteNode(imageNamed: FlowerTextureImage)
        flower.position = CGPointMake(size.width/2, size.height/2)
        flower.zPosition = Layer.Flower
        
        flower.setScale(0.5)
   
        flower.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: FlowerTextureImage), size: flower.size)
        
        flower.physicsBody!.allowsRotation = false
        flower.physicsBody!.velocity = CGVector(dx: 0.0, dy: 0.0)

        flower.physicsBody?.categoryBitMask = Category.Flower
        flower.physicsBody?.collisionBitMask = 0
        flower.physicsBody?.contactTestBitMask = Category.Stem
        flower.physicsBody?.dynamic = FlowerIsDynamicsOnStart
        
        addChild(flower)
    }
    
    private func setUpBackground(){
        
        self.backgroundColor = UIColor.darkGrayColor()
        
        let background = SKSpriteNode(imageNamed: GrassImage)
        //background.anchorPoint = CGPointMake(1, 0)
        background.position = CGPointMake(size.width/2, size.height/6)
        background.zPosition = Layer.Foreground
        background.size = CGSize(width: self.view!.bounds.size.width*2, height: self.view!.bounds.size.height  * 0.4139)
        addChild(background)
    }
    
    private func setUpStem(){
        
        //bottom
        let length = 8 * Int(UIScreen.mainScreen().scale)
        println("length: \(length)")
        let stem = StemNode(length: length)
        stem.addToScene(self, x: self.frame.size.width/2, y: self.frame.size.height/3, hidden: false)
        stem.attachToFlower(flower)
        
        //left
        let length2 = 26 * Int(UIScreen.mainScreen().scale)
        let stem2 = StemNode(length: length2)
        stem2.addToScene(self, x: 0, y: self.frame.size.height/2, hidden: true)
        stem2.attachToFlower(flower)
        
        //right
        let length3 = 26 * Int(UIScreen.mainScreen().scale)
        let stem3 = StemNode(length: length3)
        stem3.addToScene(self, x: self.frame.width, y: self.frame.height/2, hidden: true)
        stem3.attachToFlower(flower)
        
        //top
        let length4 = 16 * Int(UIScreen.mainScreen().scale)
        let stem4 = StemNode(length: length4)
        stem4.addToScene(self, x: self.frame.width/2, y: self.frame.height, hidden: true)
        stem4.attachToFlower(flower)
        
    }

    func gravityUpdated(motion: CMDeviceMotion!, error: NSError!){
        
        let grav: CMAcceleration = motion.gravity
        
        let x = CGFloat(grav.x)
        let y = CGFloat(grav.y)
        var p = CGPointMake(x, y)
        
        if (error != nil) {
            println("\(error)")
        }
        
        var orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation == UIInterfaceOrientation.LandscapeLeft{
            var t = p.x
            p.x = 0 - p.y
            p.y = t
        } else if orientation == UIInterfaceOrientation.LandscapeRight{
            var t = p.x
            p.x = p.y
            p.y = 0 - t
        } else if orientation == UIInterfaceOrientation.PortraitUpsideDown{
            p.x *= 0
            p.y *= -9.8
        }
        
        var v = CGVectorMake(p.x, 0 - p.y)
        
        //println("Gravity( dx:\(v.dx) dy:\(v.dy) )")
        physicsWorld.gravity = v
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
    }
   
}
