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
    
    @IBInspectable var index: Int = 0
    let path = UIBezierPath()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        addTarget(self, action: #selector(touchDown), for: .touchDown)
    }
    
    override func draw(_ rect: CGRect) {
        drawKeySignature(index: self.index)
    }

    func drawKeySignature(index: Int) {
        // 1
        let center = CGPoint(x: bounds.width - 5, y: bounds.height)
        
        // 3
        var startAngle: CGFloat = .pi / -2
        let endAngle: CGFloat = 2 * .pi * 0.08333333333
        
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
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
        
        if index == 1 {
            startAngle -= endAngle
        } else if index > 1 {
            for _ in 0...index-1 {
                startAngle -= endAngle
            }
        }
    }
    
    @objc func touchDown(button: KeySignatureDesignable, event: UIEvent) {
        if let touch = event.touches(for: button)?.first {
            let location = touch.location(in: button)
            
            if path.contains(location) == false {
                button.cancelTracking(with: nil)
            }
        }
        
    }
}
