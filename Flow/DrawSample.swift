//
//  DrawSample.swift
//  Flow
//
//  Created by Vince on 08/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class DrawSample: UIView {

    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()

        context?.setLineWidth(1)
        context?.setStrokeColor(UIColor.black.cgColor)
        
        context?.move(to: CGPoint(x: 50, y: 60))
        context?.addLine(to: CGPoint(x: 1000, y: 60))
        
        context?.move(to: CGPoint(x: 50, y: 70))
        context?.addLine(to: CGPoint(x: 1000, y: 70))
        
        context?.move(to: CGPoint(x: 50, y: 80))
        context?.addLine(to: CGPoint(x: 1000, y: 80))
        
        context?.move(to: CGPoint(x: 50, y: 90))
        context?.addLine(to: CGPoint(x: 1000, y: 90))
        
        context?.move(to: CGPoint(x: 50, y: 100))
        context?.addLine(to: CGPoint(x: 1000, y: 100))
        
        /*let rectangle = CGRect(x: 50, y: 50, width: 100, height: 50)
        context?.addRect(rectangle)*/
        
        context?.strokePath()
    }
}
