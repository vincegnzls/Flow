//
//  ViewController.swift
//  Flow
//
//  Created by Vince on 03/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var musicSheet: MusicSheet!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var menuBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if musicSheet != nil {
           // musicSheet.addMusicNotation()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

