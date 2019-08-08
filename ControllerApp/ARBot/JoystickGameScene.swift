//
//  JoystickGameScene.swift
//  ARBot
//
//  Created by Dhruv  Sringari on 10/12/17.
//  Copyright © 2017 Dhruv Sringari. All rights reserved.
//

import SpriteKit

let NO_CHANGE: Int = -256

class JoystickGameScene: SKScene {
    var dataDelegate: ARBotCommunicationDelegate!
    let leftAnalogStick = AnalogJoystick(diameter: 110)
    let rightAnalogStick = AnalogJoystick(diameter: 110)
    
    var leftActive = false
    var rightActive = false
    var leftSpeed: Int = 0
    var rightSpeed: Int = 0
    
    override func didMove(to view: SKView) {
        let margin: CGFloat = 20
        
        backgroundColor = .white
        leftAnalogStick.position = CGPoint(x: view.frame.midX, y: view.frame.maxY*(3/4)-margin)
        leftAnalogStick.stick.color = UIColor(red:0.93, green:0.11, blue:0.48, alpha:1.0)
        addChild(leftAnalogStick)
        
        rightAnalogStick.position = CGPoint(x: view.frame.midX, y: view.frame.midY/2+margin)
        rightAnalogStick.stick.color = UIColor(red:0.93, green:0.11, blue:0.48, alpha:1.0)
        addChild(rightAnalogStick)
        
        
        leftAnalogStick.trackingHandler =   { joystickData in
            self.leftActive = true
            self.leftSpeed = self.map(joystickData.velocity.x)
            //print("Left: \(self.leftSpeed)")
        }
        
        rightAnalogStick.trackingHandler =   { joystickData in
            self.rightActive = true
            self.rightSpeed = self.map(joystickData.velocity.x)
            //print("Right: \(self.rightSpeed)")
        }
        
        leftAnalogStick.stopHandler = {
            self.leftActive = false
            self.dataDelegate.stop(left: true, right: false)
        }
        
        rightAnalogStick.stopHandler = {
            self.rightActive = false
            self.dataDelegate.stop(left: false, right: true)
        }
    }
    
    func map(_ x: CGFloat) -> Int {
        let mapped = x.map(from: -55...55, to: -255...255)
        return Int(mapped)
    }
    
    
    // runs 60 times in a second but the update method is debounced so it only runs once every 100ms
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if leftActive && rightActive {
            dataDelegate.update(speedLeft: leftSpeed, speedRight: rightSpeed)
        } else if leftActive {
            dataDelegate.update(speedLeft: leftSpeed, speedRight: NO_CHANGE)
        } else if rightActive {
            dataDelegate.update(speedLeft: NO_CHANGE, speedRight: rightSpeed)
        }
    }
}

extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}
