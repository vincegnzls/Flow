//
//  CursorControlView.swift
//  Flow
//
//  Created by Kevin Chan on 07/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class CursorControlsView: DraggableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    func setup() {
        EventBroadcaster.instance.removeObserver(event: EventNames.PLAY_KEY_PRESSED, observer: Observer(id: "CursorControls.hideOnPlay", function: self.hideOnPlay))
        EventBroadcaster.instance.addObserver(event: EventNames.PLAY_KEY_PRESSED, observer: Observer(id: "CursorControls.hideOnPlay", function: self.hideOnPlay))

        EventBroadcaster.instance.removeObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "CursorControls.hideOnPlay", function: self.hideOnPlay))
        EventBroadcaster.instance.addObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "CursorControls.hideOnPlay", function: self.hideOnPlay))
    }

    override var keyTag: String {
        return "CursorControlsView"
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

    func hideOnPlay() {

        print("wtf")

        if !SoundManager.instance.isPlaying {
            self.isHidden = true
        } else {
            self.isHidden = false
        }
    }
}
