//
//  RectHighlightView.swift
//  Flow
//
//  Created by Kevin Chan on 03/01/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class RectHighlightView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var startPoint:CGPoint = CGPoint(x: 0.0, y: 0.0) {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var endPoint:CGPoint = CGPoint(x: 0.0, y: 0.0) {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if (startPoint != nil && endPoint != nil) {
            let path = UIBezierPath(rect: CGRect(x: min(startPoint.x, endPoint.x),
                                                              y: min(startPoint.y, endPoint.y),
                                                              width: fabs(startPoint.x - endPoint.x),
                                                              height: fabs(startPoint.y - endPoint.y)))
            // Fill
            UIColor.green.setFill()
            path.fill()
            
            path.stroke()
        }
    }
}
