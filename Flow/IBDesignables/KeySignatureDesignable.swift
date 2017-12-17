//
//  KeySignatureDesignable.swift
//  Flow
//
//  Created by Vince on 17/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class KeySignatureDesignable: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBInspectable var index: Int = 0
    @IBInspectable var outlineColor: UIColor = UIColor.black
    
    override func draw(_ rect: CGRect) {
        // 1
        let center = CGPoint(x: bounds.width - 5, y: bounds.height)
        
        // 3
        var startAngle: CGFloat = .pi / -2
        let endAngle: CGFloat = 2 * .pi * 0.08333333333
        
        UIColor.white.setFill()
        
        let path = UIBezierPath()
        
        if index == 1 {
            startAngle -= endAngle
        } else if index > 1 {
            for _ in 0...index-1 {
                startAngle -= endAngle
            }
        }
        
        path.move(to: center)
        //2 - draw the outer arc
        path.addArc(withCenter: center,
                    radius: bounds.height - 5,
                    startAngle: startAngle,
                    endAngle: startAngle - endAngle,
                    clockwise: false)
        path.move(to: center)
        
        //4 - close the path
        path.close()
        
        path.fill()
        
        outlineColor.setStroke()
        path.lineWidth = 3.5
        path.stroke()

        if index == 1 {
            startAngle -= endAngle
        } else if index > 1 {
            for _ in 0...index-1 {
                startAngle -= endAngle
            }
        }
        
    }

    func drawKeySignature(index: CGFloat) {
        
    }
}
