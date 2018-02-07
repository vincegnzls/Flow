//
//  MusicSheet.swift
//  Flow
//
//  Created by Vince on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class MusicSheet: UIView {
    
    private let HIGHLIGHTED_NOTES_TAG = 2500
    
    private let sheetYOffset:CGFloat = 20
    private let lineSpace:CGFloat = 20 // Spaces between lines in staff
    private let staffSpace:CGFloat = 260 // Spaces between staff
    private let lefRightPadding:CGFloat = 100 // Left and right padding of a staff
    private var startY:CGFloat = 200
    private var staffIndex:CGFloat = -1
    
    private let noteXOffset: CGFloat = 10
    private let noteYOffset: CGFloat = -95.5
    private let noteWidthAlter: CGFloat = -3
    private let noteHeightAlter: CGFloat = -3
    
    private let initialNoteSpace: CGFloat = 10

    private let NUM_MEASURES_PER_STAFF = 2
    
    private let yCursor = CAShapeLayer() // Horizontal cursor
    private let xCursor = CAShapeLayer() // Vertical cursor
    
    private var curYCursorLocation = CGPoint(x: 0, y: 0)
    private var curXCursorLocation = CGPoint(x: 0, y: 0)
    
    // used for connecting a grand staff
    private var measureXDivs = Set<CGFloat>()
    
    // used for tracking coordinates of measures
    private var measureCoords = [GridSystem.MeasurePoints]()
    
    private var soundManager = SoundManager()
    
    private let highlightRect = HighlightRect()
    
    public var composition: Composition?
    
    private var endX: CGFloat {
        return bounds.width - lefRightPadding
    }
    
    public var selectedNotations: [MusicNotation] = [] {
        didSet {
            print("SELECTED NOTES COUNT: " + String(selectedNotations.count))
            if selectedNotations.count == 0 {
                if let measureCoord = GridSystem.instance.selectedMeasureCoord {
                    if let newMeasure = GridSystem.instance.getMeasureFromPoints(measurePoints: measureCoord) {
                        let params:Parameters = Parameters()
                        params.put(key: KeyNames.NEW_MEASURE, value: newMeasure)
                        
                        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_SWITCHED, params: params)
                    }
                }
            } else {
                //print("ASASA")
                selectedNotes()
            }
        }
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

        /*EventBroadcaster.instance.removeObservers(event: EventNames.ADD_NEW_NOTE)
        EventBroadcaster.instance.addObserver(event: EventNames.ADD_NEW_NOTE,
                observer: Observer(id: "MusicSheet.addNewNote", function: self.addNewNote))*/
        
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
        let startPoint = startY + staffSpace * staffIndex
        
        let measureHeight = drawStaff(startX: lefRightPadding, startY: startPoint,
                clefType: upperStaffMeasures[0].clef, measures:upperStaffMeasures, withTimeSig: withTimeSig)

        staffIndex += 1
        let _ = drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex,
                clefType: lowerStaffMeasures[0].clef, measures:lowerStaffMeasures, withTimeSig: withTimeSig)

        if let height = measureHeight {
            drawStaffConnection(startX: lefRightPadding, startY: startPoint - height, height: height)
        }
    }
    
    // Draws a staff
    private func drawStaff(startX:CGFloat, startY:CGFloat, clefType:Clef, measures:[Measure], withTimeSig:Bool) -> CGFloat? {

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
        
        if let measureLocation = measureLocation {
            return measureLocation.upperLeftPoint.y - measureLocation.lowerRightPoint.y
        } else {
            return nil
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
        var clefView = UIImageView(frame: CGRect(x: 110, y: 45 + startY - 167, width: 58.2, height: 154))
        
        if clefType == .F {
            clef = UIImage(named:"bass-clef")
            clefView = UIImageView(frame: CGRect(x: 110, y: 35 + startY - 116, width: 58.2, height: 68))
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
        let snapPoints = GridSystem.instance.createSnapPoints(initialX: startX + initialNoteSpace, initialY: startY-curSpace, clef: measure.clef, lineSpace: lineSpace)
        GridSystem.instance.assignSnapPointsToPoints(measurePoints: measureCoord, snapPoint: snapPoints)
        
        // CHOOSE FIRST MEASURE COORD AS DEFAULT
        if measureCoords.count == 1 {
            GridSystem.instance.selectedMeasureCoord = measureCoord
            GridSystem.instance.selectedCoord = snapPoints[0]
            
            moveCursorY(location: snapPoints[0])
            moveCursorX(location: CGPoint(x: snapPoints[0].x, y: curYCursorLocation.y - 30))
        }
        
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
        
        // for the grand staff connection
        measureXDivs.insert(endX)

        let measureWeights = initMeasureGrid(startX: startX, endX: endX, startY: startY-curSpace)
        GridSystem.instance.assignWeightsToPoints(measurePoints: measureCoord,
                weights: measureWeights)

//        var points = snapPoints

        if measure.notationObjects.count > 0 {
            
            GridSystem.instance.clearAllSnapPointsFromMeasure(measurePoints: measureCoord)

            var notationSpace = measureCoord.width / CGFloat(measure.timeSignature.beats) // not still sure about this
            
            if measure.notationObjects.count < measure.timeSignature.beats {
                // TODO: LESSEN SPACE HERE
            } else if measure.notationObjects.count > measure.timeSignature.beats {
                notationSpace = measureCoord.width / CGFloat(measure.notationObjects.count)
            }
            
            let adjustXToCenter = initialNoteSpace*1.3
            var prevX:CGFloat?
            
            // add all notes existing in the measure
            for (index, note) in measure.notationObjects.enumerated() {

                if index == 0 {
                    note.screenCoordinates =
                            CGPoint(x: measureCoord.upperLeftPoint.x + initialNoteSpace,
                                    y: GridSystem.instance.getYFromPitch(notation: note, clef: measure.clef, snapPoints: snapPoints))
                    
                    //self.addMusicNotation(notation: note)
                    
                    GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measureCoord,
                                                                  snapPoints: GridSystem.instance.createSnapPoints(
                                                                    initialX: measureCoord.upperLeftPoint.x + initialNoteSpace + adjustXToCenter, initialY: measureCoord.lowerRightPoint.y, clef: measure.clef, lineSpace: lineSpace))
                    
                    if !measure.isFull {
                    
                        GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measureCoord,
                                                                      snapPoints: GridSystem.instance.createSnapPoints(
                                                                        initialX: measureCoord.upperLeftPoint.x + initialNoteSpace + notationSpace + adjustXToCenter, initialY: measureCoord.lowerRightPoint.y, clef: measure.clef, lineSpace: lineSpace))
                        
                        prevX = measureCoord.upperLeftPoint.x + initialNoteSpace + notationSpace + adjustXToCenter
                        
                    }
                    
                } else {
                    
                    if let prevNoteCoordinates =  measure.notationObjects[index - 1].screenCoordinates {
                    
                        note.screenCoordinates =
                            CGPoint(x: prevNoteCoordinates.x + notationSpace,
                                    y: GridSystem.instance.getYFromPitch(notation: note, clef: measure.clef, snapPoints: snapPoints))
                        
                        //self.addMusicNotation(notation: note)
                        
                        if let prevX = prevX {
                            GridSystem.instance.removeRelativeXSnapPoints(measurePoints: measureCoord, relativeX: prevX)
                        }
                        
                        GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measureCoord,
                                                                      snapPoints: GridSystem.instance.createSnapPoints(
                                                                        initialX: prevNoteCoordinates.x + notationSpace + adjustXToCenter, initialY: measureCoord.lowerRightPoint.y, clef: measure.clef, lineSpace: lineSpace))
                        
                        if !measure.isFull {
                        
                            GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measureCoord,
                                                                          snapPoints: GridSystem.instance.createSnapPoints(
                                                                            initialX: prevNoteCoordinates.x + notationSpace*2 + adjustXToCenter, initialY: measureCoord.lowerRightPoint.y, clef: measure.clef, lineSpace: lineSpace))
                            
                            prevX = prevNoteCoordinates.x + notationSpace*2 + adjustXToCenter
                            
                        }
                        
                    }
                }

            }

            // beam notes of all measures TODO: change if beaming per group is implemented
            beamNotes(notations: measure.notationObjects)

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
    private func drawStaffConnection(startX:CGFloat, startY:CGFloat, height:CGFloat) {
        let staffConnection = CAShapeLayer()
        let bezierPath = UIBezierPath()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 2
        
        for x in measureXDivs {
            bezierPath.move(to: CGPoint(x: x, y: startY))
            bezierPath.addLine(to: CGPoint(x: x, y: startY + staffSpace)) // change if staff space changes
            bezierPath.stroke()
        }
        
        staffConnection.path = bezierPath.cgPath
        staffConnection.strokeColor = UIColor.black.cgColor
        staffConnection.lineWidth = 2
        
        let brace = UIImage(named:"brace-185")
        let braceView = UIImageView(frame: CGRect(x: lefRightPadding - 25, y: startY, width: 22.4, height: staffSpace + height))
        
        measureXDivs.removeAll()
        
        braceView.image = brace
        self.addSubview(braceView)
    }

    public func addMusicNotation(notation: MusicNotation) {

        //drawBeam(notations: self.composition!.staffList[0].measures[0].notationObjects)

        var notationImageView: UIImageView

        notationImageView = UIImageView(frame: CGRect(x: ((notation.screenCoordinates)?.x)! + noteXOffset, y: ((notation.screenCoordinates)?.y)! + noteYOffset, width: (notation.image?.size.width)! + noteWidthAlter, height: (notation.image?.size.height)! + noteHeightAlter))

        notationImageView.image = notation.image
        //noteImageView.tag = 1
        
        self.addSubview(notationImageView)

        //self.assembleNoteForBeaming(notation: notation, stemHeight: 100)
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
        xPath.addLine(to: CGPoint(x: 10, y: 400))
        
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
            
            if let point = GridSystem.instance.getUpYSnapPoint(currentPoint: curYCursorLocation) {
                nextPoint = point
            } else {
                return
            }
            
        } else if direction == ArrowKey.down {
            
            if let point = GridSystem.instance.getDownYSnapPoint(currentPoint: curYCursorLocation) {
                nextPoint = point
            } else {
                return
            }
            
        } else if direction == ArrowKey.left {
            
            if let point = GridSystem.instance.getLeftXSnapPoint(currentPoint: curYCursorLocation) {
                nextPoint = point
            } else {
                return
            }
            
        } else if direction == ArrowKey.right {
            
            if let point = GridSystem.instance.getRightXSnapPoint(currentPoint: curYCursorLocation) {
                nextPoint = point
            } else {
                return
            }
            
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
        
        if selectedNotations.count > 0 {
            // Remove highlight
            while let highlightView = self.viewWithTag(HIGHLIGHTED_NOTES_TAG) {
                highlightView.removeFromSuperview()
            }
            
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

            if let firstMeasureCoord = GridSystem.instance.getFirstMeasurePointFromStaff(measurePoints: measureCoord) {

                curXCursorLocation = CGPoint(x: curYCursorLocation.x, y: firstMeasureCoord.lowerRightPoint.y - 30)
                moveCursorX(location: curXCursorLocation)
                
            }
        }

    }

    func addNewNote(params: Parameters) {
        let notation = params.get(key: KeyNames.NOTE_DETAILS) as! MusicNotation
        if let notePlacement = GridSystem.instance.getNotePlacement(notation: notation) {

            notation.screenCoordinates = notePlacement.0

            self.addMusicNotation(notation: notation)
            
            if let note = notation as? Note {
                soundManager.playSound(note)
            }

            if let coord = GridSystem.instance.selectedMeasureCoord {

                if let measure = GridSystem.instance.getMeasureFromPoints(measurePoints: coord) {
                    
                    GridSystem.instance.removeRelativeXSnapPoints(measurePoints: coord, relativeX: curYCursorLocation.x)

                    GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: coord,
                            snapPoints: GridSystem.instance.createSnapPoints(
                                    initialX: notePlacement.0.x, initialY: coord.lowerRightPoint.y,
                                    clef: measure.clef, lineSpace: lineSpace))

                    GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: coord,
                            snapPoints: GridSystem.instance.createSnapPoints(initialX: notePlacement.1.x,
                                    initialY: coord.lowerRightPoint.y,
                                    clef: measure.clef, lineSpace: lineSpace))


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
    }

    func updateMeasureDraw () {
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
            self.checkPointsInRect()
            self.highlightRect.highlightingEndPoint = nil
        } else {
            self.highlightRect.highlightingEndPoint = sender.location(in: self)
        }
    }
    
    private func checkPointsInRect() {
        
        selectedNotations.removeAll()
        
        while let highlightView = self.viewWithTag(HIGHLIGHTED_NOTES_TAG) {
            highlightView.removeFromSuperview()
        }
        
        if let allNotations = composition?.all {
            for notation in allNotations {
                if let coor = notation.screenCoordinates {
                    let rect = self.highlightRect.rect
                    if rect.contains(coor) {
                        notation.isSelected = true
                        self.selectedNotations.append(notation)
                        
                        let noteImageView = UIImageView(frame: CGRect(x: ((notation.screenCoordinates)?.x)! + noteXOffset, y: ((notation.screenCoordinates)?.y)! + noteYOffset, width: (notation.image?.size.width)! + noteWidthAlter, height: (notation.image?.size.height)! + noteHeightAlter))
                        
                        noteImageView.image = notation.image
                        noteImageView.image = noteImageView.image!.withRenderingMode(.alwaysTemplate)
                        noteImageView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                        noteImageView.tag = HIGHLIGHTED_NOTES_TAG
                        
                        self.addSubview(noteImageView)
                        
                    }
                }
            }
        }
    }
    
    public func selectedNotes() {
        if let measure = composition?.getMeasureOfNote(note: selectedNotations[0]) {
            var invalidNotes = [RestNoteType]()
            
            var totalBeats:Float = 0
            
            for note in selectedNotations {
                totalBeats = totalBeats + note.type.getBeatValue()
                print(note.type.getBeatValue())
            }
            
            let netBeatValue = measure.curBeatValue - totalBeats
            
            //print("SELECTED NOTES COUNT: " + String(selectedNotations.count))
            print("CUR MES: " + String(measure.curBeatValue))
            print("NET BEAT: " + String(netBeatValue))
            
            for noteType in RestNoteType.types {
                if netBeatValue + noteType.getBeatValue() > measure.timeSignature.getMaxBeatValue() {
                    invalidNotes.append(noteType)
                }
            }
            
            print("INVALID NOTES")
            print("COUNT: " + String(invalidNotes.count))
            
            
            for note in invalidNotes {
                print(note.toString())
            }
            
            let params = Parameters()
            
            params.put(key: KeyNames.INVALID_NOTES, value: invalidNotes)
            EventBroadcaster.instance.postEvent(event: EventNames.UPDATE_INVALID_NOTES, params: params)
        }
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
                    if let firstMeasurePoints = GridSystem.instance.getFirstMeasurePointFromStaff(measurePoints: measureCoords[indexJump]) {
                    
                        // TODO: Declare an offset for the xCursor AKA fix the hardcoded -30 below
                        moveCursorX(location: CGPoint(x: newSnapPoints[prevSnapIndex].x,
                                                      y: firstMeasurePoints.lowerRightPoint.y - 30))
                        moveCursorY(location: newSnapPoints[prevSnapIndex])
                        
                        scrollMusicSheetToY(y: measureCoords[indexJump].lowerRightPoint.y - 140)
                    }
                    
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
                        if let firstMeasurePoints = GridSystem.instance.getFirstMeasurePointFromStaff(measurePoints: measureCoords[indexJump]) {
                            
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
    }
    
    private func scrollMusicSheetToY (y: CGFloat) {
        if let outerScrollView = self.superview as? UIScrollView {
            outerScrollView.setContentOffset(
                CGPoint(x: outerScrollView.contentOffset.x, y: y), animated: true)
        }
    }
    
    public func getMeasureFromPoint (point: CGPoint) -> Measure? {
        for measurePoint in measureCoords {
            let r:CGRect = CGRect(x: measurePoint.upperLeftPoint.x, y: measurePoint.upperLeftPoint.y,
                                  width: measurePoint.lowerRightPoint.x - measurePoint.upperLeftPoint.x,
                                  height: measurePoint.lowerRightPoint.y - measurePoint.upperLeftPoint.y)
            
            //  LOCATION IS IN MEASURE
            if r.contains(point) {
                if let measure = GridSystem.instance.getMeasureFromPoints(measurePoints: measurePoint) {
                    return measure
                }
            }
        }
        
        return nil
    }

    public func getNotesBeatValue(notes: [MusicNotation]) -> Float{
        var curBeatValue: Float = 0

        for note in notes {
            curBeatValue = curBeatValue + note.type.getBeatValue()
        }

        return curBeatValue
    }

    public func drawLine(start: CGPoint, end: CGPoint, thickness: CGFloat) {
        let path = UIBezierPath()

        path.lineWidth = thickness
        path.move(to: start)
        path.addLine(to: end)
        path.stroke()
    }
    
    // BEAMS group of notes
    public func beamNotes(notations: [MusicNotation]) {
        var curNotesToBeam = [MusicNotation]()
        
        if notations.count > 1 {
            for notation in notations {
                if notation.hasTail() {
                    curNotesToBeam.append(notation)
                } else if !notation.hasTail() {
                    if curNotesToBeam.count > 1 {
                        // beam notes
                        drawBeam(notations: curNotesToBeam)
                    } else if curNotesToBeam.count == 1 {
                        addMusicNotation(notation: curNotesToBeam[0])
                    }
                    
                    addMusicNotation(notation: notation)
                    
                    curNotesToBeam.removeAll()
                }
            }
        } else if notations.count == 1 {
            //add single note
            addMusicNotation(notation: notations[0])
        }
        
        if curNotesToBeam.count > 1{
            //beam notes
            drawBeam(notations: curNotesToBeam)
        } else if curNotesToBeam.count == 1 {
            //add single note
            addMusicNotation(notation: curNotesToBeam[0])
        }
    }

    // DRAWS
    public func drawBeam(notations: [MusicNotation]) {
        var upCount: Int = 0
        var downCount: Int = 0

        let stemHeight: CGFloat = 60

        for notation in notations {
            if let note = notation as? Note {
                if note.isUpwards {
                    upCount = upCount + 1
                } else {
                    downCount = downCount + 1
                }
            }
        }

        // check whether there are more upward notes and vice versa
        if upCount > downCount {
            let highestNote = getLowestOrHighestNote(highest: true, notations: notations)
            let highestY: CGFloat = highestNote.screenCoordinates!.y - stemHeight - 5
            let startX: CGFloat = notations[0].screenCoordinates!.x + noteXOffset + 23.9
            let endX: CGFloat = notations[notations.count - 1].screenCoordinates!.x + noteXOffset + 23.9 + 2

            var curSameNotes = [MusicNotation]()

            for notation in notations {
                let curHeight = notation.screenCoordinates!.y - highestY

                assembleNoteForBeaming(notation: notation, stemHeight: curHeight, isUpwards: true)

                    if !curSameNotes.isEmpty {
                        if curSameNotes[curSameNotes.count - 1].type == notation.type {
                            curSameNotes.append(notation)
                        } else {
                            if curSameNotes.count > 1 {
                                //add appropriate flags for beaming
                                if curSameNotes[0].type == RestNoteType.sixteenth {
                                    self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4 ), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                }
                            } else if curSameNotes.count == 1 {
                                // add flag of curSameNotes[0]
                                // add flag of notation
                                if curSameNotes[0].type == RestNoteType.sixteenth {
                                    //CHECK IF LAST NOTE IF UPWARD
                                    if curSameNotes[0] === notations[notations.count - 1] {
                                        self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    } else {
                                        self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    }
                                }

                                if notation.type == RestNoteType.sixteenth {
                                    if notation === notations[notations.count - 1] {
                                        self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    } else {
                                        self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    }

                                }
                            }

                            curSameNotes.removeAll()
                            curSameNotes.append(notation)
                        }
                    } else {
                        curSameNotes.append(notation)
                    }
            }

            if curSameNotes.count > 1 {
                // add appropriate flags for beaming
                if curSameNotes[0].type == RestNoteType.sixteenth {
                    self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                }
            } else if curSameNotes.count == 1 {
                // add appripriate flag of curSameNotes[0]
                if curSameNotes[0].type == RestNoteType.sixteenth {
                    if curSameNotes[0] === notations[notations.count - 1] {
                        self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                    } else {
                        self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                    }
                }
            }

            // draws the beam based on highest note
            self.drawLine(start: CGPoint(x: startX, y: highestY), end: CGPoint(x: endX, y: highestY), thickness: lineSpace / 2)
        } else {
            let lowestNote = getLowestOrHighestNote(highest: false, notations: notations)
            let lowestY: CGFloat = lowestNote.screenCoordinates!.y + stemHeight + 3
            let startX: CGFloat = notations[0].screenCoordinates!.x + noteXOffset + 0.5
            let endX: CGFloat = notations[notations.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2

            var curSameNotes = [MusicNotation]()

            for notation in notations {
                let curHeight = lowestY - notation.screenCoordinates!.y

                assembleNoteForBeaming(notation: notation, stemHeight: curHeight, isUpwards: false)


                    if !curSameNotes.isEmpty {
                        if curSameNotes[curSameNotes.count - 1].type == notation.type {
                            curSameNotes.append(notation)
                        } else {
                            if curSameNotes.count > 1 {
                                //add appropriate flags for beaming
                                if curSameNotes[0].type == RestNoteType.sixteenth {
                                    self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4 ), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                }
                            } else if curSameNotes.count == 1 {
                                // add flag of curSameNotes[0]
                                // add flag of notation
                                if curSameNotes[0].type == RestNoteType.sixteenth {
                                    //CHECK FIRST NOTE IF DOWNWARD
                                    if curSameNotes[0] === notations[notations.count - 1] {
                                        self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    } else {
                                        self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    }
                                }

                                if notation.type == RestNoteType.sixteenth {
                                    if notation === notations[notations.count - 1] {
                                        self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    } else {
                                        self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    }
                                }
                            }

                            curSameNotes.removeAll()
                            curSameNotes.append(notation)
                        }
                    } else {
                        curSameNotes.append(notation)
                    }

            }

            if curSameNotes.count > 1 {
                // add appropriate flags for beaming
                print("I AM ALIVE")
                if curSameNotes[0].type == RestNoteType.sixteenth {
                    self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                }
            } else if curSameNotes.count == 1 {
                // add appripriate flag of curSameNotes[0]
                if curSameNotes[0].type == RestNoteType.sixteenth {
                    if curSameNotes[0] === notations[notations.count - 1] {
                        self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                    } else {
                        self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                    }
                }
            }

            // draws the beam based on lowest note
            self.drawLine(start: CGPoint(x: startX, y: lowestY), end: CGPoint(x: endX, y: lowestY), thickness: lineSpace / 2)
        }
    }

    public func assembleNoteForBeaming(notation: MusicNotation, stemHeight: CGFloat, isUpwards: Bool) {
        let noteHead = UIImage(named: "quarter-head")

        var notationImageView: UIImageView

        let noteX: CGFloat = notation.screenCoordinates!.x + noteXOffset
        let noteY: CGFloat = notation.screenCoordinates!.y + noteYOffset

        var noteWidth: CGFloat = noteHead!.size.width + noteWidthAlter
        var noteHeight: CGFloat = noteHead!.size.height + noteHeightAlter

        notationImageView = UIImageView(frame: CGRect(x: noteX, y: noteY, width: noteWidth, height: noteHeight))

        notationImageView.image = noteHead

        self.addSubview(notationImageView)

        if let note = notation as? Note {
            if isUpwards {
                self.drawLine(start: CGPoint(x: noteX + 24.9, y: noteY - noteYOffset - 5), end: CGPoint(x: noteX + 24.9, y: noteY - noteYOffset - stemHeight - 5), thickness: 2.3)
                //drawLine(start: CGPoint(x: noteX + 23.9, y: noteY - noteYOffset - stemHeight + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: noteX + 23.9 + 22, y: noteY - noteYOffset - stemHeight + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
            } else {
                self.drawLine(start: CGPoint(x: noteX + 1.5, y: noteY - noteYOffset + 3), end: CGPoint(x: noteX + 1.5, y: noteY - noteYOffset + stemHeight + 3), thickness: 2.3)
                //drawLine(start: CGPoint(x: noteX + 0.5, y: noteY - noteYOffset + stemHeight - lineSpace / 2 + lineSpace / 4), end: CGPoint(x: noteX + 0.5 + 22, y: noteY - noteYOffset + stemHeight - lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
            }
        }


    }

    public func getLowestOrHighestNote(highest: Bool, notations: [MusicNotation]) -> MusicNotation{
        var note: MusicNotation

        note = notations[0]

        for notation in notations {
            if !highest {
                if notation.screenCoordinates!.y > note.screenCoordinates!.y {
                    note = notation
                }
            } else {
                if notation.screenCoordinates!.y < note.screenCoordinates!.y {
                    note = notation
                }
            }
        }

        return note
    }

}
