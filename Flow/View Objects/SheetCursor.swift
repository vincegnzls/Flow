//
//  SheetCursor.swift
//  Flow
//
//  Created by Patrick Tobias on 28/02/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import Foundation
import UIKit

class SheetCursor : CAShapeLayer {
    
    var isXVisible = true
    var isYVisible = true
    
    private let xCursor = CAShapeLayer()
    private let yCursor = CAShapeLayer()
    
    public var curYCursorLocation = CGPoint(x: 0, y: 0)
    public var curXCursorLocation = CGPoint(x: 0, y: 0)

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
    
    // setup cursor
    private func setup () {
        yCursor.zPosition = CGFloat.greatestFiniteMagnitude // Places horizontal cursor to front
        xCursor.zPosition = CGFloat.greatestFiniteMagnitude // Places vertical cursor to front
        
        // Setup horizontal cursor
        let yPath = UIBezierPath()
        yPath.move(to: .zero)
        yPath.addLine(to: CGPoint(x: 20, y: 0))
        
        yCursor.path = yPath.cgPath
        yCursor.strokeColor = UIColor(red:0.00, green:0.47, blue:1.00, alpha:1.0).cgColor
        yCursor.lineWidth = 8
        
        // Setup vertical cursor
        let xPath = UIBezierPath()
        xPath.move(to: CGPoint(x: 10, y: 0))
        xPath.addLine(to: CGPoint(x: 10, y: 530))
        
        xCursor.path = xPath.cgPath
        xCursor.strokeColor = UIColor(red:0.00, green:0.47, blue:1.00, alpha:1.0).cgColor
        xCursor.lineWidth = 4
        
        curYCursorLocation = CGPoint(x: 300, y: 50)
        curXCursorLocation = CGPoint(x: 300, y: 50)
        
        self.addSublayer(yCursor)
        self.addSublayer(xCursor)
    }
    
    public func moveCursorX (location: CGPoint) {
        xCursor.position = location
        curXCursorLocation = location
    }
    
    public func moveCursorY (location: CGPoint) {
        yCursor.position = location
        curYCursorLocation = location
    }
    
}
