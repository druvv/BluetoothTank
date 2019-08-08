//
//  ViewController.swift
//  ARBot
//
//  Created by Dhruv  Sringari on 9/27/17.
//  Copyright © 2017 Dhruv Sringari. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol ARBotCommunicationDelegate {
    func update(speedLeft: Int, speedRight: Int)
    func stop(left: Bool, right: Bool)
}

class ViewController: UIViewController {
    
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
            print("Left: \(speedLeft)       Right: \(speedRight)")
            self.serial.sendMessageToDevice("L\(speedLeft)\nR\(speedRight)\n")
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

