//
//  ViewController.swift
//  ARBot
//
//  Created by Dhruv  Sringari on 9/27/17.
//  Copyright © 2017 Dhruv Sringari. All rights reserved.
//

import UIKit
import CoreBluetooth

enum CanonStatus {
    case uncharged
    case charging
    case readyToFire
}

enum CanonAdjustDir: Int {
    case up
    case down
    case left
    case right
    case stop
}

protocol ARBotCommunicationDelegate: class {
    func update(speedLeft: Int, speedRight: Int)
    func stop(left: Bool, right: Bool)
    func chargeCannon(miliseconds: Int)
    func fireCannon()
    func moveCannon(_ direction: CanonAdjustDir)
    var cannonStatusDidUpdate: ((CanonStatus) -> Void)? { get set }
}

class ViewController: UIViewController {

    // Will be used by delegate
    var cannonStatusDidUpdate: ((CanonStatus) -> Void)?
    
    enum BluetoothStatus {
        case off
        case searching
        case connected
        case stopped
        case unknown
    }
    
    var serial: BluetoothSerial!
    @IBOutlet var bluetoothStatusLabel: UILabel!
    var bluetoothStatus: BluetoothStatus = .off
    let limiter = TimedLimiter(limit: 0.1)

    override func viewDidLoad() {
        super.viewDidLoad()
        serial = BluetoothSerial(delegate: self)
        serial.startScan()
    }
    
    @IBAction func openPressed() {
        performSegue(withIdentifier: "openJoystick", sender: self)
    }
    
    
    func setBluetooth(status: BluetoothStatus) {
        switch status {
        case .off:
            bluetoothStatusLabel.text = "Bluetooth Off"
            bluetoothStatusLabel.textColor = UIColor.red
        case .searching:
            bluetoothStatusLabel.text = "Bluetooth Searching..."
            bluetoothStatusLabel.textColor = UIColor.orange
        case .connected:
            bluetoothStatusLabel.text = "Connected"
            bluetoothStatusLabel.textColor = UIColor.green
        case .stopped:
            bluetoothStatusLabel.text = "Bluetooth Disconnected and Not Searching"
            bluetoothStatusLabel.textColor = UIColor.red
        case .unknown:
            bluetoothStatusLabel.text = "Unknown"
            bluetoothStatusLabel.textColor = UIColor.red
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openJoystick" {
            let vc = segue.destination as! JoystickViewController
            vc.dataDelegate = self
        }
    }
    
}

extension ViewController: ARBotCommunicationDelegate {
    func chargeCannon(miliseconds: Int) {
        serial.sendMessageToDevice("A\(miliseconds)\n")
    }

    func fireCannon() {
        serial.sendMessageToDevice("S\n")
    }

    func moveCannon(_ direction: CanonAdjustDir) {
        serial.sendMessageToDevice("C\(direction.rawValue)\n")
    }


    func stop(left: Bool, right: Bool) {
        if left && right {
            self.serial.sendMessageToDevice("L0\nR0\n")
            return
        }
        
        if left {
            self.serial.sendMessageToDevice("L0\n")
        }
        
        if right {
            self.serial.sendMessageToDevice("R0\n")
        }
    }
    
    func update(speedLeft: Int, speedRight: Int) {
        limiter.execute {
            print("Left: \(speedLeft == -256 ? "nc" : String(speedLeft))       Right: \(speedRight == -256 ? "nc" : String(speedRight))")

            if speedLeft != NO_CHANGE && speedRight != NO_CHANGE {
                self.serial.sendMessageToDevice("L\(speedLeft)\nR\(speedRight)\n")
            } else if speedLeft != NO_CHANGE {
                self.serial.sendMessageToDevice("L\(speedLeft)\n")
            } else if speedRight != NO_CHANGE {
                self.serial.sendMessageToDevice("R\(speedRight)\n")
            }
        }
        
        /*
        // Debouncer
        let dispatchDelay = DispatchTimeInterval.milliseconds(500)
        let lastFireTime = DispatchTime.now()
        let dispatchTime: DispatchTime = DispatchTime.now() + dispatchDelay
        let queue = DispatchQueue.global(qos: .background)
        
        queue.asyncAfter(deadline: dispatchTime) {
            let when: DispatchTime = lastFireTime + dispatchDelay
            let now = DispatchTime.now()
            // Send the value to arduino
            if now.rawValue >= when.rawValue {
                print("Left: \(speedLeft)       Right: \(speedRight)")
                self.serial.sendMessageToDevice("\(speedLeft)/\(speedRight)\n")
            }
        }
        */
        
    }
}

extension ViewController: BluetoothSerialDelegate {
    func serialDidChangeState() {
        switch serial.centralManager.state {
        case .poweredOff:
            setBluetooth(status: .off)
        case .poweredOn:
            setBluetooth(status: .searching)
            serial.startScan()
        default:
            setBluetooth(status: .unknown)
        }
    }

    func serialDidReceiveString(_ message: String) {
        switch message {
        case "F":
            cannonStatusDidUpdate?(.uncharged)
        case "C":
            cannonStatusDidUpdate?(.charging)
        case "R":
            cannonStatusDidUpdate?(.readyToFire)
        default:
            print("Unknown message received: \(message)")
        }
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
       setBluetooth(status: .stopped)
    }
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        if peripheral.name == "BluetoothTank" {
            serial.connectToPeripheral(peripheral)
            setBluetooth(status: .connected)
        }
    }
}

