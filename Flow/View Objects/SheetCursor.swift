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
    
    private var ledgerLineGuides = [CAShapeLayer]()
    
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
        
        for _ in 0...2 {
            let ledgerLine = UIBezierPath()
            ledgerLine.move(to: CGPoint(x: 0, y: 0))
            ledgerLine.addLine(to: CGPoint(x: 30, y: 0))
            
            let ledgerGuide = CAShapeLayer()
            ledgerGuide.path = ledgerLine.cgPath
            ledgerGuide.strokeColor = UIColor(red:0, green:0, blue:0, alpha:0.65).cgColor
            ledgerGuide.lineWidth = 4
            
            self.addSublayer(ledgerGuide)
            ledgerLineGuides.append(ledgerGuide)
        }
        
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
    
    public func showLedgerLinesGuide (measurePoints: GridSystem.MeasurePoints, upToLocation: CGPoint, lineSpace:CGFloat) {
        
        for ledgerGuide in ledgerLineGuides {
            ledgerGuide.opacity = 0
            ledgerGuide.position = CGPoint(x: upToLocation.x - 5, y: (measurePoints.lowerRightPoint.y + measurePoints.upperLeftPoint.y)/2)
        }
        
        if upToLocation.y < measurePoints.lowerRightPoint.y {
            
            var currentPoint = CGPoint(x:upToLocation.x, y: measurePoints.lowerRightPoint.y - lineSpace)
            var currentGuideIndex = 0
            
            while currentPoint.y >= upToLocation.y-1.5 {
                let currentGuide = ledgerLineGuides[currentGuideIndex]
                
                currentGuide.position = CGPoint(x: currentGuide.position.x, y: currentPoint.y)
                currentGuide.opacity = 1
                
                currentPoint = CGPoint(x:currentPoint.x, y: currentPoint.y - lineSpace)
                currentGuideIndex += 1
            }
            
        } else if upToLocation.y > measurePoints.upperLeftPoint.y {
            
            var currentPoint = CGPoint(x:upToLocation.x, y: measurePoints.upperLeftPoint.y + lineSpace)
            var currentGuideIndex = 0
            
            while currentPoint.y <= upToLocation.y {
                let currentGuide = ledgerLineGuides[currentGuideIndex]
                
                currentGuide.position = CGPoint(x: currentGuide.position.x, y: currentPoint.y)
                currentGuide.opacity = 1
                
                currentPoint = CGPoint(x:currentPoint.x, y: currentPoint.y + lineSpace)
                currentGuideIndex += 1
            }
            
        }
        
    }
    
}
