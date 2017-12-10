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
    
    private let lineSpace:CGFloat = 30 // Spaces between lines in staff
    private let staffSpace:CGFloat = 280 // Spaces between staff
    private let lefRightPadding:CGFloat = 100 // Left and right padding of a staff
    private let startY:CGFloat = 200
    private let startYConnection:CGFloat = 80
    private let grandStaffSpace:CGFloat = 560 // change * 2 of staff space
    private var grandStaffIndex:CGFloat = 0
    private var staffIndex:CGFloat = -1
    
    private let yCursor = CAShapeLayer()
    private let xCursor = CAShapeLayer()
    
    private var curCursorLocation = ScreenCoordinates(x: 0, y: 0)
    
    private var grid = [Measure]()
    
    private var endX: CGFloat {
        return bounds.width - lefRightPadding
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupGrandStaff(startX: lefRightPadding, startY: startY)
        setupGrandStaff(startX: lefRightPadding, startY: startY)
        setupGrandStaff(startX: lefRightPadding, startY: startY)
        
        setupCursor()
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
        
        var clef = UIImage(named:"treble-clef")
        var clefView = UIImageView(frame: CGRect(x: 110, y: 45 + startY - 200, width: 67.2, height: 192))
        
        if clefType == .F {
            clef = UIImage(named:"bass-clef")
            clefView = UIImageView(frame: CGRect(x: 110, y: 35 + startY - 200, width: 67.2, height: 192))
        }
        
        clefView.image = clef
        self.addSubview(clefView)
        
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
        let yPath = UIBezierPath()
        yPath.move(to: .zero)
        yPath.addLine(to: CGPoint(x: 20, y: 0))

        yCursor.path = yPath.cgPath
        yCursor.strokeColor = UIColor.blue.cgColor
        yCursor.lineWidth = 3
        
        let xPath = UIBezierPath()
        xPath.move(to: CGPoint(x: 10, y: 0))
        xPath.addLine(to: CGPoint(x: 10, y: 460))
        
        xCursor.path = xPath.cgPath
        xCursor.strokeColor = UIColor.blue.cgColor
        xCursor.lineWidth = 3
        
        self.layer.addSublayer(yCursor)
        self.layer.addSublayer(xCursor)
        
        curCursorLocation = ScreenCoordinates(x: 300, y: 50)
        
        moveCursor(location: curCursorLocation)
    }
    
    private func moveCursor(location: ScreenCoordinates) {
        yCursor.position = CGPoint(x: location.x, y: location.y)
        xCursor.position = CGPoint(x: location.x, y: location.y)
    }
    
    private func moveCursorY(location: ScreenCoordinates) {
        yCursor.position = CGPoint(x: location.x, y: location.y)
    }
    
    private func moveCursorX(location: ScreenCoordinates) {
        xCursor.position = CGPoint(x: location.x, y: location.y)
    }
}
