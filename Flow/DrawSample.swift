//
//  DrawSample.swift
//  Flow
//
//  Created by Vince on 08/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class DrawSample: UIView {

    var yPosition: CGFloat = 1.0;
    
    override func draw(_ rect: CGRect) {
        
        let my = UIGraphicsGetCurrentContext()
        let staff = Staff(width: bounds.width, height: bounds.height, context: my)
        
        staff.draw(yPosition: yPosition)
        staff.draw(yPosition: yPosition)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchPoint = touches.first?.location(in: self) {
            yPosition = touchPoint.y
            updateDrawing()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateDrawing()
    }
    
    func updateDrawing(){
        self.setNeedsDisplay()
    }
}
