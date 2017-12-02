//
//  WholeNote.swift
//  Flow
//
//  Created by Vince on 24/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class WholeNote: UIButton {

    override func draw(_ rect: CGRect) {
        
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        
        //// Image Declarations
        let wholehead30 = UIImage(named: "whole-head-30.png")!
        
        //// Picture Drawing
        let picturePath = UIBezierPath(rect: CGRect(x: 0, y: 90, width: 48, height: 30))
        context.saveGState()
        picturePath.addClip()
        context.translateBy(x: 0, y: 90)
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -wholehead30.size.height)
        context.draw(wholehead30.cgImage!, in: CGRect(x: 0, y: 0, width: wholehead30.size.width, height: wholehead30.size.height))
        context.restoreGState()

    }

}
