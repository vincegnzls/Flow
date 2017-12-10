//
//  MusicSheet.swift
//  Flow
//
//  Created by Vince on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class MusicSheet: UIView {
    
    private let sheetYOffset:CGFloat = 100
    private let lineSpace:CGFloat = 30 // Spaces between lines in staff
    private let staffSpace:CGFloat = 280 // Spaces between staff
    private let lefRightPadding:CGFloat = 100 // Left and right padding of a staff
    private var startY:CGFloat = 200
    private var startYConnection:CGFloat = 80
    private let grandStaffSpace:CGFloat = 560 // change * 2 of staff space
    private var grandStaffIndex:CGFloat = 0
    private var staffIndex:CGFloat = -1
    
    private let yCursor = CAShapeLayer()
    private let xCursor = CAShapeLayer()
    
    private var curCursorYLocation = ScreenCoordinates(x: 0, y: 0)
    private var curCursorXLocation = ScreenCoordinates(x: 0, y: 0)
    
    private var grid = [Measure]()
    
    private var endX: CGFloat {
        return bounds.width - lefRightPadding
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        startY += sheetYOffset
        startYConnection += sheetYOffset
        
        setupGrandStaff(startX: lefRightPadding, startY: startY)
        setupGrandStaff(startX: lefRightPadding, startY: startY)
        setupGrandStaff(startX: lefRightPadding, startY: startY)
        
        setupCursor()
        
        EventBroadcaster.instance.addObserver(event: EventNames.ARROW_KEY_PRESSED,
                                              observer: Observer(id: "MusicSheet.onArrowKeyPressed", function: self.onArrowKeyPressed))
    }
    
    //Setup a grand staff
    private func setupGrandStaff(startX:CGFloat, startY:CGFloat) {
        staffIndex += 1
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex, clefType: Clef.G)
        staffIndex += 1
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex, clefType: Clef.F)
        drawStaffConnection(startX: lefRightPadding, startY: startYConnection + grandStaffSpace * grandStaffIndex)
        
        grandStaffIndex += 1
    }
    
    // Draws a staff
    private func drawStaff(startX:CGFloat, startY:CGFloat, clefType:Clef) {
        // Sets the line format
        let staff = CAShapeLayer()
        let bezierPath = UIBezierPath()
        
        var curSpace:CGFloat = 0
        
        // Handles adding of clef based on parameter
        var clef = UIImage(named:"treble-clef")
        var clefView = UIImageView(frame: CGRect(x: 110, y: 45 + startY - 200, width: 67.2, height: 192))
        
        if clefType == .F {
            clef = UIImage(named:"bass-clef")
            clefView = UIImageView(frame: CGRect(x: 110, y: 35 + startY - 200, width: 67.2, height: 192))
        }
        
        clefView.image = clef
        self.addSubview(clefView)
        
        // Add 5 lines
        for _ in 0..<5 {
            bezierPath.move(to: CGPoint(x: startX, y: startY - curSpace))
            bezierPath.addLine(to: CGPoint(x: endX, y: startY - curSpace))
            //bezierPath.stroke()
            
            curSpace += lineSpace
        }
        
        // Setup staff lines
        staff.path = bezierPath.cgPath
        staff.strokeColor = UIColor.black.cgColor
        staff.lineWidth = 2
        
        self.layer.addSublayer(staff)
    }

    private func drawStaffConnection(startX:CGFloat, startY:CGFloat) {
        let staffConnection = CAShapeLayer()
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: startX, y: startY))
        bezierPath.addLine(to: CGPoint(x: startX, y: startY + 400)) // change if staff space changes
        bezierPath.stroke()
        
        bezierPath.move(to: CGPoint(x: endX, y: startY))
        bezierPath.addLine(to: CGPoint(x: endX, y: startY + 400)) // change if staff space changes
        bezierPath.stroke()
        
        bezierPath.move(to: CGPoint(x: (endX + startX) / 2, y: startY))
        bezierPath.addLine(to: CGPoint(x: (endX + startX) / 2, y: startY + 400)) // change if staff space changes
        bezierPath.stroke()
        
        staffConnection.path = bezierPath.cgPath
        staffConnection.strokeColor = UIColor.black.cgColor
        staffConnection.lineWidth = 2
        
        self.layer.addSublayer(staffConnection)
        
        let brace = UIImage(named:"brace-185")
        let braceView = UIImageView(frame: CGRect(x: lefRightPadding - 25, y: startY, width: 22.4, height: 400))
        
        braceView.image = brace
        self.addSubview(braceView)
    }
    
    public func addMusicNotation(note: MusicNotation) {
        print("ADD NOTE")
        
        let noteImageView = UIImageView(frame: CGRect(x: ((note.screenCoordinates)?.x)!, y: ((note.screenCoordinates)?.y)!, width: (note.image?.size.width)!, height: (note.image?.size.height)!))
        
        noteImageView.image = note.image
        
        self.addSubview(noteImageView)
    }
    
    private func setupCursor() {
        
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
        xPath.addLine(to: CGPoint(x: 10, y: 460))
        
        xCursor.path = xPath.cgPath
        xCursor.strokeColor = UIColor(red:0.00, green:0.47, blue:1.00, alpha:1.0).cgColor
        xCursor.lineWidth = 4
        
        self.layer.addSublayer(yCursor)
        self.layer.addSublayer(xCursor)
        
        curCursorYLocation = ScreenCoordinates(x: 300, y: 50 + sheetYOffset)
        curCursorXLocation = ScreenCoordinates(x: 300, y: 50 + sheetYOffset)
        
        // Adjust initial placement of cursor
        moveCursor(location: curCursorXLocation)
    }
    
    func onArrowKeyPressed(params: Parameters) {
        let direction:ArrowKey = params.get(key: KeyNames.ARROW_KEY_DIRECTION) as! ArrowKey
        
        if direction == ArrowKey.up {
            
            curCursorYLocation.y -= 20
            moveCursorY(location: curCursorYLocation)
            
        } else if direction == ArrowKey.down {
            
            curCursorYLocation.y += 20
            moveCursorY(location: curCursorYLocation)
            
        } else if direction == ArrowKey.left {
            
            curCursorXLocation.x -= 20
            curCursorYLocation.x = curCursorXLocation.x
            moveCursorX(location: curCursorXLocation)
            moveCursorY(location: curCursorYLocation)
            
        } else if direction == ArrowKey.right {
            
            curCursorXLocation.x += 20
            curCursorYLocation.x = curCursorXLocation.x
            moveCursorX(location: curCursorXLocation)
            moveCursorY(location: curCursorYLocation)
            
        }
        
        let xLocString = "CURSOR X LOCATION: (" + String(describing: curCursorXLocation.x) + ", " + String(describing: curCursorXLocation.y) + ")"
        let yLocString = "CURSOR Y LOCATION: (" + String(describing: curCursorYLocation.x) + ", " + String(describing: curCursorYLocation.y) + ")"
        
        print(xLocString)
        print(yLocString)
    }
    
    public func moveCursor(location: ScreenCoordinates) {
        yCursor.position = CGPoint(x: location.x, y: location.y)
        xCursor.position = CGPoint(x: location.x, y: location.y)
    }
    
    public func moveCursorY(location: ScreenCoordinates) {
        yCursor.position = CGPoint(x: location.x, y: location.y)
    }
    
    public func moveCursorX(location: ScreenCoordinates) {
        xCursor.position = CGPoint(x: location.x, y: location.y)
    }
}
