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
    let stick = AnalogJoystick(diameter: 150)
    
    var leftActive = false
    var rightActive = false
    var leftSpeed: Int = 0
    var rightSpeed: Int = 0
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .white
        stick.position = CGPoint(x: view.frame.midX, y: view.frame.midY)
        stick.stick.color = UIColor(red:66/255.0, green:111/255.0, blue:245/255.0, alpha:1.0)
        addChild(stick)
        
        stick.trackingHandler = { [unowned self] joystickData in
            self.leftActive = true
            self.rightActive = true
            (self.leftSpeed, self.rightSpeed) = self.calculateSpeeds(joystickData)
        }
        
        stick.stopHandler = {
            self.leftActive = false
            self.rightActive = false
            self.dataDelegate.stop(left: true, right: true)
        }
    }

    // Returns a tuple of (leftSpeed, rightSpeed)
    func calculateSpeeds(_ data: AnalogJoystickData) -> (Int, Int) {
        let power = sqrt(pow(data.velocity.x,2) + pow(data.velocity.y, 2))
        // Converts angle from the weird output of the joystick data,
        // to one that goes from 0 - 2pi.
        var angle = convertAngle(data.angular)

        let relativeRightPower: CGFloat
        let relativeLeftPower: CGFloat

        if data.velocity.x > 0 && data.velocity.y > 0 {
            // Quadrant 1
            relativeLeftPower = 1
            relativeRightPower = powerFunc1(angle: angle)
        } else if data.velocity.x < 0 && data.velocity.y > 0 {
            // Quadrant 2
            angle = angle - (floatyPI / 2)
            angle = (floatyPI / 2) - angle // Go towards zero on the graph as angle increases...
            relativeLeftPower = powerFunc1(angle: angle)
            relativeRightPower = 1
        } else if data.velocity.x < 0 && data.velocity.y < 0 {
            // Quadrant 3
            angle = angle - floatyPI
            relativeLeftPower = -1*powerFunc2(angle: angle)
            relativeRightPower = -1*powerFunc3(angle: angle)
        } else {
            // Quadrant 4
            angle = angle - 3*floatyPI/2
            angle = floatyPI/2 - angle // Go towards zero on the graph as angle increases...
            relativeLeftPower = -1*powerFunc3(angle: angle)
            relativeRightPower = -1*powerFunc2(angle: angle)
        }

        let rightSpeed = Int(map(power * relativeRightPower))
        let leftSpeed = Int(map(power * relativeLeftPower))

        return (leftSpeed, rightSpeed)
    }

    let floatyPI = CGFloat(Double.pi)

    // Converts angle from the weird output of the joystick data,
    // to one that goes from 0 - 2pi.
    func convertAngle(_ angle: CGFloat) -> CGFloat {
        if angle >= -1*floatyPI/2 && angle <= floatyPI {
            return angle + floatyPI/2
        } else {
            return 3*floatyPI/2 + floatyPI + angle
        }
    }

    // Graph 1
    // Domain: [0, pi/2]
    // y1 = (1.5/(pi/4)) * x - 1   [0, pi/4)
    // y2 = (0.5/(pi/4)) * x       [pi/4, pi/2]
    func powerFunc1(angle: CGFloat) -> CGFloat {
        if angle < floatyPI/4 {
            let m = (1.5)/(floatyPI/4)
            return m * angle - 1
        } else {
            let m = (0.5)/(floatyPI/4)
            return m * angle
        }
    }

    // Graph 2
    // Domain: [0, pi/2]
    // y = (0.5/(pi/4)) * abs(x - (pi/4)) + 0.5
    func powerFunc2(angle: CGFloat) -> CGFloat {
        let m = (0.5)/(floatyPI/4)
        return m*abs(angle - (floatyPI/4)) + 0.5
    }

    // Graph 3
    // Domain: [0, pi/2]
    // y1 = (8/pi) * x - 1  [0, pi/4)
    // y2 = 1               [pi/4, pi/2]
    func powerFunc3(angle: CGFloat) -> CGFloat {
        if angle < (floatyPI/4) {
            let m = 8 / floatyPI
            return m * angle - 1
        } else {
            return 1
        }
    }
    
    func map(_ x: CGFloat) -> CGFloat {
        let mapped = x.map(from: -75...75, to: -255...255)
        return mapped
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        stick.position = CGPoint(x: size.width / 2, y: size.height / 2)
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
