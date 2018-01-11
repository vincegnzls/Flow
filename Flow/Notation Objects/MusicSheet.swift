//
//  MusicSheet.swift
//  Flow
//
//  Created by Vince on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

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

    private let NUM_MEASURES_PER_STAFF = 2
    
    private let yCursor = CAShapeLayer() // Horizontal cursor
    private let xCursor = CAShapeLayer() // Vertical cursor
    
    private var curYCursorLocation = CGPoint(x: 0, y: 0)
    private var curXCursorLocation = CGPoint(x: 0, y: 0)
    
    // used for connecting a grand staff
    private var measureXDivs = Set<CGFloat>()
    
    // used for tracking coordinates of measures
    private var measureCoords = [GridSystem.MeasurePoints]()
    
    private let highlightRect = HighlightRect()
    
    private var selectedMeasureCoord:GridSystem.MeasurePoints?
    
    private var composition: Composition?
    
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
        
        setupCursor()
        self.layer.addSublayer(self.highlightRect)
        
        EventBroadcaster.instance.addObserver(event: EventNames.ARROW_KEY_PRESSED,
                                              observer: Observer(id: "MusicSheet.onArrowKeyPressed", function: self.onArrowKeyPressed))
        EventBroadcaster.instance.addObserver(event: EventNames.DELETE_KEY_PRESSED,
                                              observer: Observer(id: "MusicSheet.onDeleteKeyPressed", function: self.onDeleteKeyPressed))
        EventBroadcaster.instance.addObserver(event: EventNames.VIEW_FINISH_LOADING,
                observer: Observer(id: "MusicSheet.onCompositionLoad", function: self.onCompositionLoad))
        EventBroadcaster.instance.addObserver(event: EventNames.MEASURE_UPDATE,
                                              observer: Observer(id: "MusicSheet.updateMeasureDraw", function: self.updateMeasureDraw))
        
        // Set up pan gesture for dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        panGesture.minimumNumberOfTouches = 2
        self.addGestureRecognizer(panGesture)
    }

    func onCompositionLoad (params: Parameters) {
        composition = params.get(key: KeyNames.COMPOSITION) as? Composition
    }
    
    override func draw(_ rect: CGRect) {
        if let composition = composition {
            var measureSplices = [[Measure]]()

            // compute number of staff divisions
            let numStaffDivs = composition.numMeasures / (NUM_MEASURES_PER_STAFF * composition.numStaves)

            var startIndex = 0
            for i in 0..<numStaffDivs {
                measureSplices.append([Measure]())
                for k in 0..<composition.numStaves {
                    measureSplices[i].append(contentsOf: Array(composition.staffList[k].measures[startIndex...startIndex + (NUM_MEASURES_PER_STAFF-1)]))
                }

                startIndex += NUM_MEASURES_PER_STAFF

            }

            // TODO: fix this if there are changing time signatures and key signatures between measure splices
            setupGrandStaff(startX: lefRightPadding, startY: startY, withTimeSig: true, measures: measureSplices[0])

            for i in 1..<measureSplices.count {
                setupGrandStaff(startX: lefRightPadding, startY: startY, withTimeSig: false, measures: measureSplices[i])
            }
        }
    }
    
    //Setup a grand staff
    private func setupGrandStaff(startX:CGFloat, startY:CGFloat, withTimeSig:Bool, measures:[Measure]) {

        let lowerStaffStart = measures.count/2

        var upperStaffMeasures = [Measure]()
        var lowerStaffMeasures = [Measure]()

        for i in 0...lowerStaffStart-1 {
            upperStaffMeasures.append(measures[i])
        }

        for i in lowerStaffStart...measures.count-1 {
            lowerStaffMeasures.append(measures[i])
        }

        staffIndex += 1
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex, clefType: upperStaffMeasures[0].clef, measures:upperStaffMeasures, withTimeSig: withTimeSig)
        staffIndex += 1
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex, clefType: lowerStaffMeasures[0].clef, measures:lowerStaffMeasures, withTimeSig: withTimeSig)
        drawStaffConnection(startX: lefRightPadding, startY: startYConnection + grandStaffSpace * grandStaffIndex)
        
        grandStaffIndex += 1
    }
    
    // Draws a staff
    private func drawStaff(startX:CGFloat, startY:CGFloat, clefType:Clef, measures:[Measure], withTimeSig:Bool) {
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
        let distance:CGFloat = (endX-startMeasure)/CGFloat(measures.count)
    
        var modStartX:CGFloat = startMeasure
        for i in 0...measures.count-1 {
            var measureLocation:GridSystem.MeasurePoints?
            if i == 0 {
                measureLocation = drawMeasure(startX: modStartX, endX:modStartX+distance, startY: startY, withLeftLine: false)

            } else {
                measureLocation = drawMeasure(startX: modStartX, endX: modStartX+distance, startY: startY)
            }

            GridSystem.instance.assignMeasureToPoints(measurePoints: measureLocation!, measure: measures[i])
            
            modStartX = modStartX + distance
        }
    }
    
    // Draws the clef and time before the staff
    private func drawClefTimeLabel(startX:CGFloat, startY:CGFloat, clefType:Clef) {
        
        drawClefLabel(startX: startX, startY: startY, clefType: clefType)
        
        // TODO: implement switch case for time sig
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
    private func drawMeasure(startX:CGFloat, endX:CGFloat, startY:CGFloat, withLeftLine:Bool = true) -> GridSystem.MeasurePoints {
        
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

        // get upper left point and lower right point of measure to keep track of location
        let measureCoord:GridSystem.MeasurePoints =
            GridSystem.MeasurePoints(upperLeftPoint: CGPoint(x: startX, y: startY), lowerRightPoint: CGPoint(x: endX, y: startY-curSpace))
        
        measureCoords.append(measureCoord)
        
        //GridSystem.sharedInstance?.assignMeasureToPoints(measurePoints: measureCoord, measure: grid[grid.count - 1])
        // TODO: FIX HARDCODED PADDING FOR SNAP POINTS
        GridSystem.instance.assignSnapPointsToPoints(measurePoints: measureCoord, snapPoint: createSnapPoints(initialX: startX + 20, initialY: startY-curSpace))
        
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

        return measureCoord
    }
    
    // Initializes the Grid System
    private func initMeasureGrid (startX:CGFloat, endX:CGFloat, startY:CGFloat) -> [CGPoint] {
        
        // init padding for left and right
        let paddingLeftRight:CGFloat = 20
        
        // TODO: IMPLEMENT TIME SIGNATURE PARAMETER; DELETE THIS AFTER DOING TODO
        let topNumber:Int = 4
        let bottomNumber:Int = 4
        
        // init array of points
        var points = [CGPoint]()
        
        // init current x with respect to padding
        var currX = startX + paddingLeftRight
        
        // calculate the maximum 64 notes per measure
        let maximum64th = (64/bottomNumber) * topNumber
        
        // calculate distance between two points
        let distance:CGFloat = ((endX - paddingLeftRight) - currX) / CGFloat(maximum64th)
        
        // create points tantamount to maximum number of 64th notes
        for _ in 1...maximum64th {
            points.append(CGPoint(x: currX, y: startY/2))
            
            currX += distance
        }
        
        return points
        
    }
    
    private func createSnapPoints (initialX: CGFloat, initialY: CGFloat) -> [CGPoint] {
        var snapPoints = [CGPoint]()
        
        var currSnapPoint:CGPoint = CGPoint(x: initialX, y: initialY)
        
        for i in 1...9 {
            snapPoints.append(currSnapPoint)
            
            if i % 2 == 0 {
                currSnapPoint = CGPoint(x: currSnapPoint.x, y: currSnapPoint.y + 16.5)
            } else {
                currSnapPoint = CGPoint(x: currSnapPoint.x, y: currSnapPoint.y + 13.5)
            }
        }
        
        return snapPoints
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
        //noteImageView.tag = 1
        
        self.addSubview(noteImageView)
    }
    
    private func setupCursor() {
        
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
        xPath.addLine(to: CGPoint(x: 10, y: 460))
        
        xCursor.path = xPath.cgPath
        xCursor.strokeColor = UIColor(red:0.00, green:0.47, blue:1.00, alpha:1.0).cgColor
        xCursor.lineWidth = 4
        
        self.layer.addSublayer(yCursor)
        self.layer.addSublayer(xCursor)
        
        curYCursorLocation = CGPoint(x: 300, y: 50 + sheetYOffset)
        curXCursorLocation = CGPoint(x: 300, y: 50 + sheetYOffset)
        
        // Adjust initial placement of cursor
        moveCursor(location: curXCursorLocation)
    }
    
    func onArrowKeyPressed(params: Parameters) {
        let direction:ArrowKey = params.get(key: KeyNames.ARROW_KEY_DIRECTION) as! ArrowKey
        
        if direction == ArrowKey.up {
            
            curYCursorLocation.y -= 15
            moveCursorY(location: curYCursorLocation)
            
        } else if direction == ArrowKey.down {
            
            curYCursorLocation.y += 15
            moveCursorY(location: curYCursorLocation)
            
        } else if direction == ArrowKey.left {
            
            let note = MusicNotation(type: .whole)
            note.screenCoordinates = curYCursorLocation
            note.image = UIImage(named: "whole-head")
            
            addMusicNotation(note: note)
            
            curXCursorLocation.x -= 40
            curYCursorLocation.x = curXCursorLocation.x
            moveCursorX(location: curXCursorLocation)
            moveCursorY(location: curYCursorLocation)
            
        } else if direction == ArrowKey.right {
            
            let note = MusicNotation(type: .whole)
            note.screenCoordinates = curYCursorLocation
            note.image = UIImage(named: "whole-head")
            
            addMusicNotation(note: note)
            
            curXCursorLocation.x += 40
            curYCursorLocation.x = curXCursorLocation.x
            moveCursorX(location: curXCursorLocation)
            moveCursorY(location: curYCursorLocation)
            
        }
        
        let xLocString = "CURSOR X LOCATION: (" + String(describing: curXCursorLocation.x) + ", " + String(describing: curXCursorLocation.y) + ")"
        let yLocString = "CURSOR Y LOCATION: (" + String(describing: curYCursorLocation.x) + ", " + String(describing: curYCursorLocation.y) + ")"
        
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
        
        //print("LOCATION TAPPED: \(location)")
        
        if self.highlightRect.isVisible {
            self.highlightRect.highlightingStartPoint = nil
            self.highlightRect.highlightingEndPoint = nil
            return
        }
        
        remapCurrentMeasure(location: location)
        
        // START FOR SNAPPING
        
        if let measureCoord = GridSystem.instance.selectedMeasureCoord {

            if let snapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: measureCoord) {

                var closestPoint: CGPoint = snapPoints[0];

                let x2: CGFloat = location.x - snapPoints[0].x
                let y2: CGFloat = location.y - snapPoints[0].y

                var currDistance: CGFloat = (x2 * x2) + (y2 * y2)

                for i in 1...snapPoints.count - 1 {
                    let x2: CGFloat = location.x - snapPoints[i].x
                    let y2: CGFloat = location.y - snapPoints[i].y

                    let potDistance = (x2 * x2) + (y2 * y2)

                    if (potDistance < currDistance) {
                        currDistance = potDistance
                        closestPoint = snapPoints[i]
                    }
                }

                let relXLocation = CGPoint(x: closestPoint.x, y: curXCursorLocation.y)

                //print("NEAREST POINT: \(closestPoint)")

                curXCursorLocation = relXLocation
                moveCursorX(location: relXLocation)

                curYCursorLocation = closestPoint
                moveCursorY(location: closestPoint)

            }
        }
        
        // END FOR SNAPPING
    }
    
    private func remapCurrentMeasure (location:CGPoint) {
        
        for (index, measureCoord) in measureCoords.enumerated() {
            let r:CGRect = CGRect(x: measureCoord.upperLeftPoint.x, y: measureCoord.upperLeftPoint.y,
                                  width: measureCoord.lowerRightPoint.x - measureCoord.upperLeftPoint.x,
                                  height: measureCoord.lowerRightPoint.y - measureCoord.upperLeftPoint.y)
            
            //  LOCATION IS IN MEASURE
            if r.contains(location) {
                print("MEASURE #\(index) TAPPED")
                
                GridSystem.instance.selectedMeasureCoord = measureCoord
                
                if let measure = GridSystem.instance.getMeasureFromPoints(measurePoints: measureCoord) {
                    print("MEASURE CONTAINS: \(measure.notationObjects)")
                    print("MEASURE HAS: \(measure.clef)")
                }
                break
            }
        }
        
    }
    
    func onDeleteKeyPressed() {
        print("DELETE CALLED")
        
        var subViews = self.subviews
        
        //ALTERNATIVE : self.view.viewWithTag(100)
        
        if let viewWithTag = subViews.popLast() {
            print("Tag 1")
            viewWithTag.removeFromSuperview()
        }
        else {
            print("tag not found")
        }
    }

    func updateMeasureDraw(params: Parameters) {
        // TODO: update view here
        print("VIEW SHOULD UPDATE NOW !!!")

        let notation = params.get(key: KeyNames.NOTE_DETAILS) as! MusicNotation
        notation.screenCoordinates = curYCursorLocation

        self.addMusicNotation(note: notation)
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let locationOfBeganTap = sender.location(in: self)
            self.highlightRect.highlightingStartPoint = locationOfBeganTap
            self.highlightRect.highlightingEndPoint = locationOfBeganTap
            
        } else if sender.state == UIGestureRecognizerState.ended {
            self.highlightRect.highlightingEndPoint = sender.location(in: self)
        } else{
            self.highlightRect.highlightingEndPoint = sender.location(in: self)
        }
    }
}
