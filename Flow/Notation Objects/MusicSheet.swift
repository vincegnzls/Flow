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
    
    // TO REMOVE LATER ON; USED FOR TESTING PURPOSES ONLY
    
    private var snapPoints = [CGPoint]()
    
    // END OF REMOVE LATER
    
    private let sheetYOffset:CGFloat = 60
    private let lineSpace:CGFloat = 30 // Spaces between lines in staff
    private let staffSpace:CGFloat = 280 // Spaces between staff
    private let lefRightPadding:CGFloat = 100 // Left and right padding of a staff
    private var startY:CGFloat = 200
    private var startYConnection:CGFloat = 80
    private let grandStaffSpace:CGFloat = 560 // change * 2 of staff space
    private var grandStaffIndex:CGFloat = 0
    private var staffIndex:CGFloat = -1
    
    private let yCursor = CAShapeLayer() // Horizontal cursor
    private let xCursor = CAShapeLayer() // Vertical cursor
    
    private var curCursorYLocation = CGPoint(x: 0, y: 0)
    private var curCursorXLocation = CGPoint(x: 0, y: 0)
    
    private var measureXDivs = Set<CGFloat>()
    private var grid = [Measure]()
    
    private var endX: CGFloat {
        return bounds.width - lefRightPadding
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        startY += sheetYOffset
        startYConnection += sheetYOffset
        
        // TO REMOVE IN FUTURE (FOR TESTING)
        
        var currSnapPoint:CGPoint = CGPoint(x: 264.5, y: 140.5)
        
        for i in 1...9 {
            snapPoints.append(currSnapPoint)
            
            if i % 2 == 0 {
                currSnapPoint = CGPoint(x: currSnapPoint.x, y: currSnapPoint.y + 16.5)
            } else {
                currSnapPoint = CGPoint(x: currSnapPoint.x, y: currSnapPoint.y + 13.5)
            }
        }
        
        // END REMOVE
        
        setupCursor()
        
        EventBroadcaster.instance.addObserver(event: EventNames.ARROW_KEY_PRESSED,
                                              observer: Observer(id: "MusicSheet.onArrowKeyPressed", function: self.onArrowKeyPressed))
    }
    
    override func draw(_ rect: CGRect) {
        setupGrandStaff(startX: lefRightPadding, startY: startY, withTimeSig: true)
        setupGrandStaff(startX: lefRightPadding, startY: startY, withTimeSig: false)
        setupGrandStaff(startX: lefRightPadding, startY: startY, withTimeSig: false)
    }
    
    //Setup a grand staff
    private func setupGrandStaff(startX:CGFloat, startY:CGFloat, withTimeSig:Bool) {
        staffIndex += 1
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex, clefType: Clef.G, numMeasures:2, withTimeSig: withTimeSig)
        staffIndex += 1
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex, clefType: Clef.F, numMeasures:2, withTimeSig: withTimeSig)
        drawStaffConnection(startX: lefRightPadding, startY: startYConnection + grandStaffSpace * grandStaffIndex)
        
        grandStaffIndex += 1
    }
    
    // Draws a staff
    private func drawStaff(startX:CGFloat, startY:CGFloat, clefType:Clef, numMeasures:CGFloat, withTimeSig:Bool) {
        // Handles adding of clef based on parameter
        if withTimeSig {
            drawClefTimeLabel(startX: startX, startY: startY, clefType: clefType)
        } else {
            drawClefLabel(startX: startX, startY: startY, clefType: clefType)
        }
        
        // Adjust initial space for clef and time signature
        var startMeasure:CGFloat = 0
        
        if withTimeSig {
            startMeasure = startX + 160
        } else {
            startMeasure = startX + 85
        }

        // Track distance for each measure to be printed
        let distance:CGFloat = (endX-startMeasure)/numMeasures
    
        var modStartX:CGFloat = startMeasure
        for i in 1...Int(numMeasures) {
            if i == 1 {
                drawMeasure(startX: modStartX, endX:modStartX+distance, startY: startY, withLeftLine: false)
            } else {
                drawMeasure(startX: modStartX, endX: modStartX+distance, startY: startY)
            }
            
            modStartX = modStartX + distance
        }
    }
    
    // Draws the clef and time before the staff
    private func drawClefTimeLabel(startX:CGFloat, startY:CGFloat, clefType:Clef) {
        
        drawClefLabel(startX: startX, startY: startY, clefType: clefType)
        
        // TODO implement switch case for time sig
        let upperTimeSig = UIImage(named:"numeral-4")
        let lowerTimeSig = UIImage(named:"numeral-4")
        
        let upperTimeView = UIImageView(frame: CGRect(x:195 ,y: startY - 120, width:52, height:61))
        let lowerTimeView = UIImageView(frame: CGRect(x:195 ,y: startY - 60, width:52, height:61))
        
        upperTimeView.image = upperTimeSig
        lowerTimeView.image = lowerTimeSig
        
        self.addSubview(upperTimeView)
        self.addSubview(lowerTimeView)
    }
    
    // Draws the clef before the staff
    private func drawClefLabel(startX: CGFloat, startY: CGFloat, clefType: Clef) {
        var clef = UIImage(named:"treble-clef")
        var clefView = UIImageView(frame: CGRect(x: 110, y: 45 + startY - 200, width: 67.2, height: 192))
        
        if clefType == .F {
            clef = UIImage(named:"bass-clef")
            clefView = UIImageView(frame: CGRect(x: 110, y: 35 + startY - 200, width: 67.2, height: 192))
        }
        
        clefView.image = clef
        self.addSubview(clefView)
        
        // START Draw lines for clef
        let bezierPath = UIBezierPath()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        
        var curSpace:CGFloat = 0
        
        // Draws 5 lines
        for _ in 0..<5 {
            bezierPath.move(to: CGPoint(x: startX, y: startY - curSpace))
            bezierPath.addLine(to: CGPoint(x: endX, y: startY - curSpace))
            bezierPath.stroke()
            
            curSpace += lineSpace
        }
        
        curSpace -= lineSpace // THIS IS NECESSARY FOR ADJUSTING THE LEFT LINE
        
        // Draws left vertical line
        bezierPath.move(to: CGPoint(x: startX, y: startY - curSpace))
        bezierPath.addLine(to: CGPoint(x: startX, y: startY)) // change if staff space changes
        bezierPath.stroke()
        
        measureXDivs.insert(startX)
        
        // END Draw lines for clef
    }
    
    // Draws a measure
    private func drawMeasure(startX:CGFloat, endX:CGFloat, startY:CGFloat, withLeftLine:Bool = true) {
        
        let bezierPath = UIBezierPath()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        
        var curSpace:CGFloat = 0
        
        //draw 5 lines
        for _ in 0..<5 {
            bezierPath.move(to: CGPoint(x: startX, y: startY - curSpace))
            bezierPath.addLine(to: CGPoint(x: endX, y: startY - curSpace))
            bezierPath.stroke()
            
            curSpace += lineSpace
        }
        
        curSpace -= lineSpace // THIS IS NECESSARY FOR ADJUSTING THE LEFT AND RIGHT LINES
        
        //draw line before measure
        if withLeftLine {
            bezierPath.move(to: CGPoint(x: startX, y: startY - curSpace))
            bezierPath.addLine(to: CGPoint(x: startX, y: startY)) // change if staff space changes
            bezierPath.stroke()
            
            measureXDivs.insert(startX)
        }
        
        //draw line after measure
        bezierPath.move(to: CGPoint(x: endX, y: startY - curSpace))
        bezierPath.addLine(to: CGPoint(x: endX, y: startY)) // change if staff space changes
        bezierPath.stroke()
        
        measureXDivs.insert(endX)
        
    }

    // Draws connecting lines for grand staves
    private func drawStaffConnection(startX:CGFloat, startY:CGFloat) {
        let staffConnection = CAShapeLayer()
        let bezierPath = UIBezierPath()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        
        for x in measureXDivs {
            bezierPath.move(to: CGPoint(x: x, y: startY))
            bezierPath.addLine(to: CGPoint(x: x, y: startY + 400)) // change if staff space changes
            bezierPath.stroke()
        }
        
        staffConnection.path = bezierPath.cgPath
        staffConnection.strokeColor = UIColor.black.cgColor
        staffConnection.lineWidth = 2
        
        let brace = UIImage(named:"brace-185")
        let braceView = UIImageView(frame: CGRect(x: lefRightPadding - 25, y: startY, width: 22.4, height: 400))
        
        measureXDivs.removeAll()
        
        braceView.image = brace
        self.addSubview(braceView)
    }
    
    public func addMusicNotation(note: MusicNotation) {
        print("ADD NOTE")
        
        let noteImageView = UIImageView(frame: CGRect(x: ((note.screenCoordinates)?.x)! + 1.8, y: ((note.screenCoordinates)?.y)! - 5, width: (note.image?.size.width)!, height: (note.image?.size.height)!))
        
        noteImageView.image = note.image
        
        self.addSubview(noteImageView)
    }
    
    private func setupCursor() {
        
        yCursor.zPosition = .greatestFiniteMagnitude // Places horizontal cursor to front
        xCursor.zPosition = .greatestFiniteMagnitude // Places vertical cursor to front
        
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
        
        curCursorYLocation = CGPoint(x: 300, y: 50 + sheetYOffset)
        curCursorXLocation = CGPoint(x: 300, y: 50 + sheetYOffset)
        
        // Adjust initial placement of cursor
        moveCursor(location: curCursorXLocation)
    }
    
    func onArrowKeyPressed(params: Parameters) {
        let direction:ArrowKey = params.get(key: KeyNames.ARROW_KEY_DIRECTION) as! ArrowKey
        
        if direction == ArrowKey.up {
            
            curCursorYLocation.y -= 15
            moveCursorY(location: curCursorYLocation)
            
        } else if direction == ArrowKey.down {
            
            curCursorYLocation.y += 15
            moveCursorY(location: curCursorYLocation)
            
        } else if direction == ArrowKey.left {
            
            let note = MusicNotation()
            note.screenCoordinates = curCursorYLocation
            note.image = UIImage(named: "whole-head")
            
            addMusicNotation(note: note)
            
            curCursorXLocation.x -= 40
            curCursorYLocation.x = curCursorXLocation.x
            moveCursorX(location: curCursorXLocation)
            moveCursorY(location: curCursorYLocation)
            
        } else if direction == ArrowKey.right {
            
            let note = MusicNotation()
            note.screenCoordinates = curCursorYLocation
            note.image = UIImage(named: "whole-head")
            
            addMusicNotation(note: note)
            
            curCursorXLocation.x += 40
            curCursorYLocation.x = curCursorXLocation.x
            moveCursorX(location: curCursorXLocation)
            moveCursorY(location: curCursorYLocation)
            
        }
        
        let xLocString = "CURSOR X LOCATION: (" + String(describing: curCursorXLocation.x) + ", " + String(describing: curCursorXLocation.y) + ")"
        let yLocString = "CURSOR Y LOCATION: (" + String(describing: curCursorYLocation.x) + ", " + String(describing: curCursorYLocation.y) + ")"
        
        print(xLocString)
        print(yLocString)
    }
    
    public func moveCursor(location: CGPoint) {
        yCursor.position = location
        xCursor.position = location
    }
    
    public func moveCursorY(location: CGPoint) {
        yCursor.position = location
    }
    
    public func moveCursorX(location: CGPoint) {
        xCursor.position = location
    }
    
    // used for
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        print("LOCATION TAPPED: \(location)")
        
        var closestPoint:CGPoint = snapPoints[0];
        
        let x2:CGFloat = location.x - snapPoints[0].x
        let y2:CGFloat = location.y - snapPoints[0].y
        
        var currDistance:CGFloat = (x2 * x2) + (y2 * y2)
        
        for i in 1...snapPoints.count-1 {
            let x2:CGFloat = location.x - snapPoints[i].x
            let y2:CGFloat = location.y - snapPoints[i].y
            
            let potDistance = (x2 * x2) + (y2 * y2)
            
            if (potDistance < currDistance) {
                currDistance = potDistance
                closestPoint = snapPoints[i]
            }
        }
        
        let relXLocation = CGPoint(x: closestPoint.x, y: curCursorXLocation.y)
        
        print("NEAREST POINT: \(closestPoint)")
        
        curCursorXLocation = relXLocation
        moveCursorX(location: relXLocation)
        
        curCursorYLocation = closestPoint
        moveCursorY(location: closestPoint)
    }
}
