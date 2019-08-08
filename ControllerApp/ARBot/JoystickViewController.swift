//
//  JoystickViewController.swift
//  ARBot
//
//  Created by Dhruv  Sringari on 10/20/17.
//  Copyright © 2017 Dhruv Sringari. All rights reserved.
//

import UIKit
import SpriteKit

class JoystickViewController: UIViewController {
    @IBOutlet weak var skView: SKView!
    var dataDelegate: ARBotCommunicationDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = JoystickGameScene(size: view.bounds.size)
        scene.dataDelegate = dataDelegate
        scene.scaleMode = .resizeFill
        skView.isMultipleTouchEnabled = true
        skView.presentScene(scene)
    }
    
    @IBAction func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
