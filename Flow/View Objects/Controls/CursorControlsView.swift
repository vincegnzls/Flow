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
    
    private func animate(_ sender: UIButton) {
        sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.5, options: .allowUserInteraction, animations:
            {
                sender.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @IBAction func tapUpArrowKey(_ sender: UIButton) {
        //print("Up")
        self.arrowKeyTapped(direction: ArrowKey.up)
        
        animate(sender)
    }
    
    @IBAction func tapDownArrowKey(_ sender: UIButton) {
        //print("Down")
        self.arrowKeyTapped(direction: ArrowKey.down)
        
        animate(sender)
    }
    
    @IBAction func tapRightArrowKey(_ sender: UIButton) {
        //print("Right")
        self.arrowKeyTapped(direction: ArrowKey.right)
        
        animate(sender)
    }
    
    @IBAction func tapLeftArrowKey(_ sender: UIButton) {
        //print("Left")
        self.arrowKeyTapped(direction: ArrowKey.left)
        
        animate(sender)
    }
    
    func arrowKeyTapped(direction: ArrowKey) {
        let params = Parameters()
        params.put(key: KeyNames.ARROW_KEY_DIRECTION, value: direction)
        EventBroadcaster.instance.postEvent(event: EventNames.ARROW_KEY_PRESSED, params: params)
    }
}
