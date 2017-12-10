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
        //print("Up")
        self.arrowKeyTapped(direction: ArrowKey.up)
    }
    
    @IBAction func tapDownArrowKey(_ sender: UIButton) {
        //print("Down")
        self.arrowKeyTapped(direction: ArrowKey.down)
    }
    
    @IBAction func tapRightArrowKey(_ sender: UIButton) {
        //print("Right")
        self.arrowKeyTapped(direction: ArrowKey.right)
    }
    
    @IBAction func tapLeftArrowKey(_ sender: UIButton) {
        //print("Left")
        self.arrowKeyTapped(direction: ArrowKey.left)
    }
    
    func arrowKeyTapped(direction: ArrowKey) {
        let params = Parameters()
        params.put(key: KeyNames.ARROW_KEY_DIRECTION, value: direction)
        EventBroadcaster.instance.postEvent(event: EventNames.ARROW_KEY_PRESSED, params: params)
    }
}
