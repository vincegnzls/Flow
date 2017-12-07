//
//  ControlsView.swift
//  Flow
//
//  Created by Kevin Chan on 07/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class ControlsView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        if let superview = self.superview {
            superview.bringSubview(toFront: self)
            
            let safeArea = superview.safeAreaInsets
            let translation = sender.translation(in: superview)
            var newCenterX = self.center.x + translation.x
            var newCenterY = self.center.y + translation.y
            
            // Validation to prevent controls from being dragged outside of the screen
            if newCenterX + self.bounds.width / 2 >= superview.bounds.width {
                newCenterX = superview.bounds.width - self.bounds.width / 2
            } else if newCenterX <= self.bounds.width / 2 {
                newCenterX = self.bounds.width / 2
            }
            
            if newCenterY + self.bounds.height / 2 >= superview.bounds.height {
                newCenterY = superview.bounds.height - self.bounds.height / 2
            } else if newCenterY <= self.bounds.height / 2 + safeArea.top {
                newCenterY = self.bounds.height / 2 + safeArea.top
            }
            
            self.center = CGPoint(x: newCenterX, y: newCenterY)
            sender.setTranslation(CGPoint.zero, in: superview)
        }
        
    }
}
