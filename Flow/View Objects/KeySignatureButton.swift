//
//  KeySignatureButton.swift
//  Flow
//
//  Created by Vince on 13/04/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import UIKit

class KeySignatureButton: UIButton {
    
    var keySignature: KeySignature = .c
    var isOn = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 4.5, options: .allowUserInteraction, animations:
            {
                self.transform = CGAffineTransform.identity
        }, completion: nil)
        
        super.touchesBegan(touches, with: event)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }

    func initButton() {
        layer.cornerRadius = self.bounds.size.width / 2
        layer.backgroundColor = UIColor.darkGray.cgColor
        addTarget(self, action: #selector(KeySignatureButton.buttonPressed), for: .touchUpInside)
        
        //EventBroadcaster.instance.removeObserver(event: EventNames.SELECT_KEY_SIGNATURE, observer: Observer(id: "KeySignatureButton.selectButton", function: self.selectButton))
        EventBroadcaster.instance.addObserver(event: EventNames.SELECT_KEY_SIGNATURE,
                                              observer: Observer(id: "KeySignatureButton.selectButton", function: self.selectButton))
    }
    
    @objc
    func buttonPressed() {
        let params = Parameters()
        
        params.put(key: KeyNames.SELECTED_KEY_SIG, value: self.keySignature)
        EventBroadcaster.instance.postEvent(event: EventNames.SELECT_KEY_SIGNATURE, params: params)
    }
    
    func selectButton(params: Parameters) {
        self.isOn = true
        
        let keySig: KeySignature = params.get(key: KeyNames.SELECTED_KEY_SIG) as! KeySignature
        
        if keySig == self.keySignature {
            let btnColor: CGColor = UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1.0).cgColor
            layer.backgroundColor = btnColor
        } else {
            layer.backgroundColor = UIColor.darkGray.cgColor
        }
    }
}
