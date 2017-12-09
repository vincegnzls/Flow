//
//  CursorControlView.swift
//  Flow
//
//  Created by Kevin Chan on 07/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class CursorControlsView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    private func setup() {
        
    }
    
    @IBAction func tapUpArrowKey(_ sender: UIButton) {
        print("Up")
    }
    
    @IBAction func tapDownArrowKey(_ sender: UIButton) {
        print("Down")
    }
    
    @IBAction func tapRightArrowKey(_ sender: UIButton) {
        print("Right")
    }
    
    @IBAction func tapLeftArrowKey(_ sender: UIButton) {
        print("Left")
    }
}
