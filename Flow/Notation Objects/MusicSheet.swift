//
//  MusicSheet.swift
//  Flow
//
//  Created by Vince on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class MusicSheet: UIView {
    
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
    
    public var composition: Composition?
    
    private var endX: CGFloat {
        return bounds.width - lefRightPadding
    }
    
    private var selectedNotations: [MusicNotation] = []
    
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
        /*EventBroadcaster.instance.addObserver(event: EventNames.DELETE_KEY_PRESSED,
                                              observer: Observer(id: "MusicSheet.onDeleteKeyPressed", function: self.onDeleteKeyPressed))*/
        EventBroadcaster.instance.addObserver(event: EventNames.VIEW_FINISH_LOADING,
                observer: Observer(id: "MusicSheet.onCompositionLoad", function: self.onCompositionLoad))
        EventBroadcaster.instance.addObserver(event: EventNames.STAFF_SWITCHED,
                observer: Observer(id: "MusicSheet.onStaffSwitch", function: self.onStaffChange))

        EventBroadcaster.instance.removeObservers(event: EventNames.MEASURE_UPDATE)
        EventBroadcaster.instance.addObserver(event: EventNames.MEASURE_UPDATE,
                                              observer:  Observer(id: "MusicSheet.updateMeasureDraw", function: self.updateMeasureDraw))

        EventBroadcaster.instance.removeObservers(event: EventNames.ADD_NEW_NOTE)
        EventBroadcaster.instance.addObserver(event: EventNames.ADD_NEW_NOTE,
                observer: Observer(id: "MusicSheet.addNewNote", function: self.addNewNote))
        
        // Set up pan gesture for dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        panGesture.minimumNumberOfTouches = 2
        self.addGestureRecognizer(panGesture)
    }

    func onCompositionLoad (params: Parameters) {
        //composition = params.get(key: KeyNames.COMPOSITION) as? Composition
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
                    measureSplices[i].append(
                            contentsOf: Array(composition.staffList[k].measures[startIndex...startIndex + (NUM_MEASURES_PER_STAFF-1)]))
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

        GridSystem.instance.createNewMeasurePointsArray()

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
        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex,
                clefType: upperStaffMeasures[0].clef, measures:upperStaffMeasures, withTimeSig: withTimeSig)

        staffIndex += 1

        drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex,
                clefType: lowerStaffMeasures[0].clef, measures:lowerStaffMeasures, withTimeSig: withTimeSig)

        drawStaffConnection(startX: lefRightPadding, startY: startYConnection + grandStaffSpace * grandStaffIndex)
        
        grandStaffIndex += 1
    }
    
    // Draws a staff
    private func drawStaff(startX:CGFloat, startY:CGFloat, clefType:Clef, measures:[Measure], withTimeSig:Bool) {

        // Handles adding of clef based on parameter
        // TODO: SHIFT THIS TO BE DRAWN PER MEASURE
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

        // Start drawing the measures
        var modStartX:CGFloat = startMeasure
        var measureLocation:GridSystem.MeasurePoints?

        for i in 0...measures.count-1 {

            if i == 0 {
                measureLocation = drawMeasure(
                        measure: measures[i], startX: modStartX, endX:modStartX+distance, startY: startY, withLeftLine: false)

            } else {
                measureLocation = drawMeasure(
                        measure: measures[i], startX: modStartX, endX: modStartX+distance, startY: startY)
            }

            if let measureLocation = measureLocation {
                GridSystem.instance.assignMeasureToPoints(measurePoints: measureLocation, measure: measures[i])
                GridSystem.instance.appendMeasurePointToLatestArray(measurePoints: measureLocation)
            }
            
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
    private func drawMeasure(measure: Measure, startX:CGFloat, endX:CGFloat, startY:CGFloat, withLeftLine:Bool = true) -> GridSystem.MeasurePoints {
        
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
        let snapPoints = GridSystem.instance.createSnapPoints(initialX: startX + 20, initialY: startY-curSpace, clef: measure.clef)
        GridSystem.instance.assignSnapPointsToPoints(measurePoints: measureCoord, snapPoint: snapPoints)
        
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

        let measureWeights = initMeasureGrid(startX: startX, endX: endX, startY: startY-curSpace)
        GridSystem.instance.assignWeightsToPoints(measurePoints: measureCoord,
                weights: measureWeights)

        if measure.clef == .G {
            print(measure.notationObjects.count)
        }

        var points = snapPoints

        if measure.notationObjects.count > 0 {
            
            GridSystem.instance.removeRelativeXSnapPoints(measurePoints: measureCoord, relativeX: points[0].x)

            // add all notes existing in the measure
            for (index, note) in measure.notationObjects.enumerated() {

                let coordinates:(CGPoint, CGPoint)?

                coordinates = GridSystem.instance.getNotePlacement(
                        notation: note, clef: measure.clef, snapPoints: points, weights: measureWeights)

                if let coordinates = coordinates {

                    note.screenCoordinates = coordinates.0

                    points = GridSystem.instance.createSnapPoints(
                            initialX: coordinates.1.x, initialY: coordinates.1.y, clef: measure.clef)
                    GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measureCoord, snapPoints: points)

                    GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measureCoord,
                            snapPoints: GridSystem.instance.createSnapPoints(
                                    initialX: coordinates.0.x, initialY: measureCoord.lowerRightPoint.y, clef: measure.clef))

                    if index != measure.notationObjects.count-1 {
                        GridSystem.instance.removeRelativeXSnapPoints(measurePoints: measureCoord, relativeX: coordinates.1.x)
                    }
                    
                    self.addMusicNotation(note: note)

                }
            }

        }

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
        for _ in 0..<maximum64th {
            points.append(CGPoint(x: currX, y: startY))
            
            currX += distance
        }
        
        return points
        
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
        var nextPoint:CGPoint = curYCursorLocation
        
        if direction == ArrowKey.up {
            nextPoint = GridSystem.instance.getUpYSnapPoint(currentPoint: curYCursorLocation)
        } else if direction == ArrowKey.down {
            nextPoint = GridSystem.instance.getDownYSnapPoint(currentPoint: curYCursorLocation)
        } else if direction == ArrowKey.left {
            nextPoint = GridSystem.instance.getLeftXSnapPoint(currentPoint: curYCursorLocation)
        } else if direction == ArrowKey.right {
            nextPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: curYCursorLocation)
        }
        
        // go to next measure with the same clef
        if nextPoint == curYCursorLocation {
            if let measurePoints = GridSystem.instance.selectedMeasureCoord {
                
                if direction == ArrowKey.left {
                    moveCursorsToPreviousMeasure(measurePoints: measurePoints)
                } else if direction == ArrowKey.right {
                    moveCursorsToNextMeasure(measurePoints: measurePoints)
                }
            }
        } else {
            curXCursorLocation.x = nextPoint.x
            curYCursorLocation.x = nextPoint.x
            
            moveCursorX(location: curXCursorLocation)
            moveCursorY(location: nextPoint)
        }
        
        
        GridSystem.instance.selectedCoord = curYCursorLocation
        
        /*let xLocString = "CURSOR X LOCATION: (" + String(describing: curXCursorLocation.x) + ", " + String(describing: curXCursorLocation.y) + ")"
        let yLocString = "CURSOR Y LOCATION: (" + String(describing: curYCursorLocation.x) + ", " + String(describing: curYCursorLocation.y) + ")"
        
        print(xLocString)
        print(yLocString)*/
    }
    
    public func moveCursor(location: CGPoint) {
        yCursor.position = location
        xCursor.position = location
    }
    
    public func moveCursorY(location: CGPoint) {
        yCursor.position = location
        curYCursorLocation = location
    }
    
    public func moveCursorX(location: CGPoint) {
        xCursor.position = location
        curXCursorLocation = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        //print("LOCATION TAPPED: \(location)")
        
        if self.highlightRect.isVisible {
            // Remove highlight
            self.highlightRect.highlightingStartPoint = nil
            self.highlightRect.highlightingEndPoint = nil
            
            // Remove selected notes
            for note in selectedNotations {
                note.isSelected = false
            }
            self.selectedNotations.removeAll()
            
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

                for snapPoint in snapPoints {
                    let x2: CGFloat = location.x - snapPoint.x
                    let y2: CGFloat = location.y - snapPoint.y

                    let potDistance = (x2 * x2) + (y2 * y2)

                    if (potDistance < currDistance) {
                        currDistance = potDistance
                        closestPoint = snapPoint
                    }
                }

                let newXCurLocation = CGPoint(x: closestPoint.x, y: curXCursorLocation.y)
                
                curXCursorLocation = newXCurLocation
                moveCursorX(location: newXCurLocation)

                curYCursorLocation = closestPoint
                moveCursorY(location: closestPoint)

                GridSystem.instance.selectedCoord = closestPoint

                print("PITCH: \(GridSystem.instance.getPitchFromY(y: closestPoint.y).step.toString())")

            }

            GridSystem.instance.currentStaffIndex =
                    GridSystem.instance.getStaffIndexFromMeasurePoint(measurePoints: measureCoord)
        }
        
        // END FOR SNAPPING
    }
    
    private func remapCurrentMeasure (location:CGPoint) {
        
        for measureCoord in measureCoords {
            let r:CGRect = CGRect(x: measureCoord.upperLeftPoint.x, y: measureCoord.upperLeftPoint.y,
                                  width: measureCoord.lowerRightPoint.x - measureCoord.upperLeftPoint.x,
                                  height: measureCoord.lowerRightPoint.y - measureCoord.upperLeftPoint.y)
            
            //  LOCATION IS IN MEASURE
            if r.contains(location) {
                GridSystem.instance.selectedMeasureCoord = measureCoord
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

    func onStaffChange() {

        if let measureCoord = GridSystem.instance.selectedMeasureCoord {

            let firstMeasureCoord = GridSystem.instance.getFirstMeasurePointFromStaff(measurePoints: measureCoord)

            curXCursorLocation = CGPoint(x: curYCursorLocation.x, y: firstMeasureCoord.lowerRightPoint.y - 30)
            moveCursorX(location: curXCursorLocation)

        }

    }

    func addNewNote(params: Parameters) {
        let notation = params.get(key: KeyNames.NOTE_DETAILS) as! MusicNotation
        let notePlacement = GridSystem.instance.getNotePlacement(notation: notation)

        notation.screenCoordinates = notePlacement.0

        self.addMusicNotation(note: notation)

        if let coord = GridSystem.instance.selectedMeasureCoord {

            if let measure = GridSystem.instance.getMeasureFromPoints(measurePoints: coord) {
                
                GridSystem.instance.removeRelativeXSnapPoints(measurePoints: coord, relativeX: curYCursorLocation.x)

                GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: coord,
                        snapPoints: GridSystem.instance.createSnapPoints(
                                initialX: notePlacement.0.x, initialY: coord.lowerRightPoint.y,
                                clef: measure.clef))

                GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: coord,
                        snapPoints: GridSystem.instance.createSnapPoints(initialX: notePlacement.1.x,
                                initialY: coord.lowerRightPoint.y,
                                clef: measure.clef))


                if measure.isFull {
                    
                    moveCursorsToNextMeasure(measurePoints: coord)
                    
                } else {
                    GridSystem.instance.selectedCoord = CGPoint(x: notePlacement.1.x, y: curYCursorLocation.y)
                    
                    moveCursorX(location: CGPoint(x: notePlacement.1.x, y: curXCursorLocation.y))
                    moveCursorY(location: GridSystem.instance.selectedCoord!)
                }

            }

        }

    }

    func updateMeasureDraw () {
        grandStaffIndex = 0
        startY = 200 + sheetYOffset
        staffIndex = -1

        for subview in self.subviews {
            subview.removeFromSuperview()
        }

        self.setNeedsDisplay()

        print("finished updating the view")
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
        
        self.checkPointsInRect()
    }
    
    private func checkPointsInRect() {
        if let allNotations = composition?.all {
            for notation in allNotations {
                if let coor = notation.screenCoordinates {
                    let rect = self.highlightRect.rect
                    if rect.contains(coor) {
                        notation.isSelected = true
                        self.selectedNotations.append(notation)
                    }
                }
            }
        }
    }
    
    public func getSelectedNotes() -> [MusicNotation] {
        return self.selectedNotations
    }
    
    private func moveCursorsToNextMeasure(measurePoints: GridSystem.MeasurePoints) { // relative to clef
        if let currIndex = measureCoords.index(of: measurePoints) {
            
            // get previous snap points
            let prevSnapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: measurePoints)
            
            // get current index of previous snap points
            if let prevSnapIndex = prevSnapPoints?.index(where: {$0.y == curYCursorLocation.y}) {
                
                let indexJump:Int
                
                // for jumping to relative measure with the same clef
                if currIndex % NUM_MEASURES_PER_STAFF == NUM_MEASURES_PER_STAFF-1 {
                    indexJump = currIndex + NUM_MEASURES_PER_STAFF + 1
                    
                    if indexJump >= measureCoords.count {
                        return
                    }
                    
                    GridSystem.instance.currentStaffIndex =
                        GridSystem.instance.getStaffIndexFromMeasurePoint(measurePoints: measureCoords[indexJump])
                } else {
                    indexJump = currIndex+1
                    
                    if indexJump >= measureCoords.count {
                        return
                    }
                }
                
                // get new snap points from next measure
                if let newSnapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: measureCoords[indexJump]) {
                    
                    GridSystem.instance.selectedMeasureCoord = measureCoords[indexJump]
                    GridSystem.instance.selectedCoord = newSnapPoints[prevSnapIndex]
                    
                    // get first measure points of the
                    let firstMeasurePoints = GridSystem.instance.getFirstMeasurePointFromStaff(measurePoints: measureCoords[indexJump])
                    
                    // TODO: Declare an offset for the xCursor AKA fix the hardcoded -30 below
                    moveCursorX(location: CGPoint(x: newSnapPoints[prevSnapIndex].x,
                                                  y: firstMeasurePoints.lowerRightPoint.y - 30))
                    moveCursorY(location: newSnapPoints[prevSnapIndex])
                    
                    scrollMusicSheetToY(y: measureCoords[indexJump].lowerRightPoint.y - 140)
                    
                }
                
            }
        }
    }
    
    // ONLY USE THIS IF YOU ARE SELECTING SNAP POINTS IN THE FIRST COLUMN
    private func moveCursorsToPreviousMeasure(measurePoints: GridSystem.MeasurePoints) { // relative to clef
        if let currIndex = measureCoords.index(of: measurePoints) {
            
            // get previous snap points
            if let prevSnapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: measurePoints){
            
                // get current index of previous snap points
                
                if let prevSnapIndex = prevSnapPoints.index(where: {$0.y == curYCursorLocation.y}) {
                    let indexJump:Int
                    
                    // for jumping to relative measure with the same clef
                    if currIndex % NUM_MEASURES_PER_STAFF == 0 {
                        
                        indexJump = currIndex - (NUM_MEASURES_PER_STAFF + 1)
                        
                        if indexJump < 0 {
                            return
                        }
                        
                        GridSystem.instance.currentStaffIndex =
                            GridSystem.instance.getStaffIndexFromMeasurePoint(measurePoints: measureCoords[indexJump])
                        
                    } else {
                        
                        indexJump = currIndex-1
                        
                        if indexJump < 0 {
                            return
                        }
                        
                    }
                    
                    // get new snap points from next measure
                    if let newSnapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: measureCoords[indexJump]) {
                        
                        GridSystem.instance.selectedMeasureCoord = measureCoords[indexJump]
                        
                        let newCoord = newSnapPoints[(newSnapPoints.count-1) - (GridSystem.NUMBER_OF_SNAPPOINTS_PER_COLUMN - prevSnapIndex)]
                        
                        GridSystem.instance.selectedCoord = newCoord
                        
                        // get first measure points of the
                        let firstMeasurePoints = GridSystem.instance.getFirstMeasurePointFromStaff(measurePoints: measureCoords[indexJump])
                        
                        // TODO: Declare an offset for the xCursor AKA fix the hardcoded -30 below
                        moveCursorX(location: CGPoint(x: newCoord.x,
                                                      y: firstMeasurePoints.lowerRightPoint.y - 30))
                        moveCursorY(location: newCoord)
                        
                        scrollMusicSheetToY(y: measureCoords[indexJump].lowerRightPoint.y - 140)
                    }
                    
                }
            }
        }
    }
    
    private func scrollMusicSheetToY (y: CGFloat) {
        if let outerScrollView = self.superview as? UIScrollView {
            outerScrollView.setContentOffset(
                CGPoint(x: outerScrollView.contentOffset.x, y: y), animated: true)
        }
    }

}
