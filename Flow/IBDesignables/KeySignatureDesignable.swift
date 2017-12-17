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

    private struct Constants {
        static let numberOfGlasses = 8
        static let lineWidth: CGFloat = 5.0
        static let arcWidth: CGFloat = 76
        
        static var halfOfLineWidth: CGFloat {
            return lineWidth / 2
        }
    }
    
    @IBInspectable var counter: Int = 5
    @IBInspectable var outlineColor: UIColor = UIColor.blue
    @IBInspectable var counterColor: UIColor = UIColor.orange
    
    override func draw(_ rect: CGRect) {
        // 1
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        // 3
        let startAngle: CGFloat = .pi
        let endAngle: CGFloat = 3 * .pi
        
        
        //2 - draw the outer arc
        let outlinePath = UIBezierPath(arcCenter: center,
                                       radius: bounds.width/2,
                                       startAngle: startAngle,
                                       endAngle: endAngle,
                                       clockwise: true)
        
        //4 - close the path
        outlinePath.close()
        
        outlineColor.setStroke()
        outlinePath.lineWidth = Constants.lineWidth
        outlinePath.stroke()
    }

}
