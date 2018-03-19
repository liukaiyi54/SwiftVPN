//
//  ViewController.swift
//  SwiftVPN
//
//  Created by Michael on 15/03/2018.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import NetworkExtension

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var connectButton: UIButton!
    
    @IBAction func didTapConnect(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
}

