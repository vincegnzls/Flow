//
//  Line.swift
//  Flow
//
//  Created by Vince on 08/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class Line: UIButton {

    override func draw(_ rect: CGRect) {
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: bounds.height/2))
        bezierPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height/2))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.stroke()
    }
}
