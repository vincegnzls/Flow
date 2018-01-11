//
//  HighlightRect.swift
//  Flow
//
//  Created by Kevin Chan on 09/01/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import Foundation
import UIKit

class HighlightRect: CAShapeLayer {
    
    var isVisible = false
    var highlightingStartPoint: CGPoint? {
        didSet {
            self.update()
        }
    }
    var highlightingEndPoint: CGPoint? {
        didSet {
            self.update()
        }
    }
    
    override init() {
        super.init()
        self.setup()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        let rect = CGRect()
        self.path = CGPath(rect: rect, transform: nil)
        
        // Fill
        let highlightColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.3)
        self.fillColor = highlightColor.cgColor
        
        // Line Width
        self.lineWidth = 0
        
//        let bezierPath: UIBezierPath?
//        if let startPoint = self.highlightingStartPoint, let endPoint = self.highlightingEndPoint {
//            bezierPath = UIBezierPath(rect: CGRect(x: min(startPoint.x, endPoint.x),
//                                             y: min(startPoint.y, endPoint.y),
//                                             width: fabs(startPoint.x - endPoint.x),
//                                             height: fabs(startPoint.y - endPoint.y)))
//            // Fill
//            let highlightColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.3)
//            highlightColor.setFill()
//            bezierPath!.fill()
//
//            // Stroke
//            bezierPath!.lineWidth = 0
//
//            bezierPath!.stroke()
//        } else {
//            bezierPath = nil
//        }
    }
    
    private func update() {
        if let startPoint = self.highlightingStartPoint, let endPoint = self.highlightingEndPoint {
            let rect = CGRect(x: min(startPoint.x, endPoint.x),
                              y: min(startPoint.y, endPoint.y),
                              width: fabs(startPoint.x - endPoint.x),
                              height: fabs(startPoint.y - endPoint.y))
            
            self.path = CGPath(rect: rect, transform: nil)
            self.isVisible = true
        } else {
            self.path = CGPath(rect: CGRect(), transform: nil)
            self.isVisible = false
        }
    }
    
}
