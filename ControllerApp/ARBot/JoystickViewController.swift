//
//  JoystickViewController.swift
//  ARBot
//
//  Created by Dhruv  Sringari on 10/20/17.
//  Copyright © 2017 Dhruv Sringari. All rights reserved.
//

import UIKit
import SpriteKit

class JoystickViewController: UIViewController, ARBotCommunicationDelegate {

    // Unused
    var cannonStatusDidUpdate: ((CanonStatus) -> Void)?

    @IBOutlet var skView: SKView!
    weak var dataDelegate: ARBotCommunicationDelegate?

    @IBOutlet var chargeButton: UIButton!
    @IBOutlet var fireButton: UIButton!

    @IBOutlet var cannonStatusLabel: UILabel!

    @IBOutlet var leftSpeedLabel: UILabel!
    @IBOutlet var rightSpeedLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = JoystickGameScene(size: skView.bounds.size)
        scene.dataDelegate = self
        scene.scaleMode = .resizeFill
        skView.isMultipleTouchEnabled = true
        skView.presentScene(scene)

        dataDelegate?.cannonStatusDidUpdate = { newStatus in
            self.handleStatus(newStatus)
        }

        let twoFingerTap = UITapGestureRecognizer(target: self, action: #selector(toggleCommandLock))
        twoFingerTap.numberOfTouchesRequired = 2
        view.addGestureRecognizer(twoFingerTap)

        unlockCommands()
    }

    func handleStatus(_ status: CanonStatus) {
        switch status {
        case .uncharged:
            chargeButton.isEnabled = true
            fireButton.isEnabled = false
            cannonStatusLabel.text = "Uncharged"
            cannonStatusLabel.textColor = .darkGray
        case .charging:
            cannonStatusLabel.text = "Charging..."
            cannonStatusLabel.textColor = UIColor(red:1.00, green:0.60, blue:0.00, alpha:1.0)
        case .readyToFire:
            cannonStatusLabel.text = "Ready to fire"
            cannonStatusLabel.textColor = UIColor(red:0.09, green:0.93, blue:0.16, alpha:1.0)
        }
    }

    var commandsLocked = false

    @objc func toggleCommandLock() {
        if commandsLocked {
            unlockCommands()
        } else {
            lockCommands()
        }

        commandsLocked = !commandsLocked
    }

    func unlockCommands() {
        dataDelegate?.cannonStatusDidUpdate = { _ in }
        chargeButton.isEnabled = true
        fireButton.isEnabled = true
        cannonStatusLabel.text = "All Commands Unlocked"
        cannonStatusLabel.textColor = .purple
    }

    func lockCommands() {
        dataDelegate?.cannonStatusDidUpdate = { newStatus in
            self.handleStatus(newStatus)
        }
        handleStatus(.uncharged)
    }
    
    @IBAction func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        skView.scene?.size = skView.bounds.size
    }

    @IBAction func upPressed() {
        dataDelegate?.moveCannon(.up)
    }

    @IBAction func downPressed() {
         dataDelegate?.moveCannon(.down)
    }

    @IBAction func leftPressed() {
         dataDelegate?.moveCannon(.left)
    }

    @IBAction func rightPressed() {
         dataDelegate?.moveCannon(.right)
    }

    @IBAction func touchUp() {
         dataDelegate?.moveCannon(.stop)
    }

    @IBAction func charge() {
        dataDelegate?.chargeCannon(miliseconds: 2 * 1000) // 10 seconds
    }

    @IBAction func fire() {
        dataDelegate?.fireCannon()
    }


    func update(speedLeft: Int, speedRight: Int) {
        dataDelegate?.update(speedLeft: speedLeft, speedRight: speedRight)

        if speedLeft != NO_CHANGE {
            leftSpeedLabel.text = "\(speedLeft)"
        }

        if speedRight != NO_CHANGE {
            rightSpeedLabel.text = "\(speedRight)"
        }

    }

    func stop(left: Bool, right: Bool) {
        dataDelegate?.stop(left: left, right: right)

        if left {
            leftSpeedLabel.text = "0"
        }

        if right {
            rightSpeedLabel.text = "0"
        }
    }

    func chargeCannon(miliseconds: Int) {
        // Unused
    }

    func fireCannon() {
        // Unused
    }

    func moveCannon(_ direction: CanonAdjustDir) {
        // Unused
    }

}
