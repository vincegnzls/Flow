//
//  ButtonEffect.swift
//  Flow
//
//  Created by Vince on 13/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class ButtonEffect: UIButton {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.5, options: .allowUserInteraction, animations:
            {
                self.transform = CGAffineTransform.identity
        }, completion: nil)
        
        
    }

}
