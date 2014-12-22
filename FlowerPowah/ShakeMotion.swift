//
//  ShakeMotion.swift
//  FlowerPowah
//
//  Created by Kj Drougge on 2014-12-22.
//  Copyright (c) 2014 kj. All rights reserved.
//

import Foundation
import CoreMotion

@objc protocol ShakeMotionDeligate
{
    func shakeFound()
    
}

class ShakeMotion: NSObject {
    
    var deligate:ShakeMotionDeligate?
    
    let motionManager: CMMotionManager = CMMotionManager()
    
    var lastX: Double = 0.0;
    var lastY: Double = 0.0;
    var lastZ: Double = 0.0;
    
    var values:[Double] = [];
    
    
    func startShake(){
        
        
        self.motionManager.accelerometerUpdateInterval = 0.1;
        if motionManager.accelerometerAvailable{
            let queue = NSOperationQueue()
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler:
                {(data: CMAccelerometerData!, error: NSError!) in
                    
                    var value = abs(data.acceleration.x+data.acceleration.y+data.acceleration.z-self.lastX-self.lastY-self.lastZ)
                    
                    self.values.append(value)
                    
                    if( self.values.count >= 10){
                        self.values.removeAtIndex(0)
                    }
                    
                    var sum = self.values.reduce(0, combine: +)
                    
                    
                    println("Sum is \(sum)");
                    
                    if(sum/10 > Double(3.5)){
                        
                        self.deligate?.shakeFound();
                        
                        /* FUNGERAR INTE ATT DISPATCH TILL MAIN???????!?!?
                        dispatch_async(dispatch_get_main_queue(), {
                        self.deligate?.shakeFound();
                        
                        });
                        */
                        sum = 0;
                        self.values.removeAll(keepCapacity: true);
                    }
                    
                    
                    self.lastX = data.acceleration.x;
                    self.lastY = data.acceleration.y;
                    self.lastZ = data.acceleration.z;
                    
                    
                }
            )
        } else {
            println("Accelerometer is not available")
        }
    }
    
    func stopShake(){
        motionManager.stopAccelerometerUpdates()
    }
    
    
    
    
    
    
}
