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
    private let TIME_SIGNATURES_TAG = 2501
    
    private let sheetYOffset:CGFloat = 20
    private let lineSpace:CGFloat = 20 // Spaces between lines in staff
    private let staffSpace:CGFloat = 260 // Spaces between staff
    private let lefRightPadding:CGFloat = 100 // Left and right padding of a staff
    private var startY:CGFloat = 200
    private var staffIndex:CGFloat = -1
    
    private let noteXOffset: CGFloat = 10
    private let noteYOffset: CGFloat = -93
    private let noteWidthAlter: CGFloat = -3
    private let noteHeightAlter: CGFloat = -3
    
    private let restYOffset: CGFloat = -0.5
    private let restWidthAlter: CGFloat = 1.7
    private let restHeightAlter: CGFloat = 1.7
    
    private let initialNoteSpace: CGFloat = 10
    private let adjustToXCenter: CGFloat = 1.3

    private let NUM_MEASURES_PER_STAFF = 2
    
    // used for connecting a grand staff
    private var measureXDivs = Set<CGFloat>()
    
    // used for tracking coordinates of measures
    private var measureCoords = [GridSystem.MeasurePoints]()
    
    private let highlightRect = HighlightRect()
    private let sheetCursor = SheetCursor()
    private let cursorXOffsetY:CGFloat = -95 // distance of starting y from measure
    
    public var composition: Composition?
    public var hoveredNotation: MusicNotation?

    private var curScale: CGFloat = 1.0
    var originalCenter:CGPoint?

    var isZooming = false
    
    private var endX: CGFloat {
        return bounds.width - lefRightPadding
    }
    
    private var visibleLedgerLines = [UIBezierPath]()
    
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
                selectedNotes()
            }
        }
    }
    
    public var selectedClef: Clef?
    
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
        
        highlightRect.zPosition = CGFloat.greatestFiniteMagnitude
        self.layer.addSublayer(self.highlightRect)
        
        sheetCursor.zPosition = CGFloat.greatestFiniteMagnitude - 1
        self.layer.addSublayer(self.sheetCursor)
        
        EventBroadcaster.instance.removeObservers(event: EventNames.ARROW_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.ARROW_KEY_PRESSED,
                                              observer: Observer(id: "MusicSheet.onArrowKeyPressed", function: self.onArrowKeyPressed))
        
        EventBroadcaster.instance.addObserver(event: EventNames.VIEW_FINISH_LOADING,
                observer: Observer(id: "MusicSheet.onCompositionLoad", function: self.onCompositionLoad))
        
        EventBroadcaster.instance.removeObservers(event: EventNames.STAFF_SWITCHED)
        EventBroadcaster.instance.addObserver(event: EventNames.STAFF_SWITCHED,
                observer: Observer(id: "MusicSheet.onStaffSwitch", function: self.onStaffChange))
        
        EventBroadcaster.instance.removeObservers(event: EventNames.MEASURE_UPDATE)
        EventBroadcaster.instance.addObserver(event: EventNames.MEASURE_UPDATE,
                                              observer:  Observer(id: "MusicSheet.updateMeasureDraw", function: self.updateMeasureDraw))

        // Add listeners for cut/copy/paste events
        EventBroadcaster.instance.removeObservers(event: EventNames.COPY_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.COPY_KEY_PRESSED, observer: Observer(id: "MusicSheet.copy", function: self.copy))

        EventBroadcaster.instance.removeObservers(event: EventNames.CUT_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.CUT_KEY_PRESSED, observer: Observer(id: "MusicSheet.cut", function: self.cut))

        EventBroadcaster.instance.removeObservers(event: EventNames.PASTE_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.PASTE_KEY_PRESSED, observer: Observer(id: "MusicSheet.paste", function: self.paste))

        EventBroadcaster.instance.removeObservers(event: EventNames.EDIT_TIME_SIG)
        EventBroadcaster.instance.addObserver(event: EventNames.EDIT_TIME_SIG, observer: Observer(id: "MusicSheet.editTimeSig", function: self.editTimeSig))

        EventBroadcaster.instance.removeObservers(event: EventNames.EDIT_KEY_SIG)
        EventBroadcaster.instance.addObserver(event: EventNames.EDIT_KEY_SIG, observer: Observer(id: "MusicSheet.editKeySig", function: self.editKeySig))
        
        EventBroadcaster.instance.removeObservers(event: EventNames.TITLE_CHANGED)
        EventBroadcaster.instance.addObserver(event: EventNames.TITLE_CHANGED, observer: Observer(id: "MusicSheet.titleChanged", function: self.titleChanged))

        // Add listeners for accidentals
        EventBroadcaster.instance.removeObservers(event: EventNames.NATURALIZE_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.NATURALIZE_KEY_PRESSED, observer: Observer(id: "MusicSheet.naturalize", function: self.naturalize))

        EventBroadcaster.instance.removeObservers(event: EventNames.FLAT_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.FLAT_KEY_PRESSED, observer: Observer(id: "MusicSheet.flat", function: self.flat))

        EventBroadcaster.instance.removeObservers(event: EventNames.SHARP_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.SHARP_KEY_PRESSED, observer: Observer(id: "MusicSheet.sharp", function: self.sharp))

        EventBroadcaster.instance.removeObservers(event: EventNames.DSHARP_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.DSHARP_KEY_PRESSED, observer: Observer(id: "MusicSheet.dsharp", function: self.dsharp))

        // Set up pan gesture for dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        panGesture.maximumNumberOfTouches = 1
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

            // for redirecting the cursor after a full measure
            for i in 1..<measureSplices.count {
                setupGrandStaff(startX: lefRightPadding, startY: startY, withTimeSig: false, measures: measureSplices[i])
            }
            
            // for redirecting the cursor after redrawing the whole composition
            if let recentNotation = GridSystem.instance.recentNotation {
                
                if let measure = GridSystem.instance.getCurrentMeasure() {
                    
                    /*if measure.isFull {
                        if let measureCoord = GridSystem.instance.selectedMeasureCoord {
                            self.moveCursorsToNextMeasure(measurePoints: measureCoord)
                            return
                        }
                    }*/
                    
                    if measure.notationObjects.contains(recentNotation) {
                        var coordForCurrentPoint:CGPoint?
                        
                        if let coord = recentNotation.screenCoordinates {
                            
                            if recentNotation is Note {
                                coordForCurrentPoint = coord
                            } else if recentNotation is Rest {
                                coordForCurrentPoint = sheetCursor.curYCursorLocation
                            }
                            
                        }
                        
                        if let noteScreenCoord = coordForCurrentPoint {
                            
                            if let snapPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: noteScreenCoord) {
                                
                                // get right again to go to the next
                                if let nextSnapPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: snapPoint) {
                                    
                                    GridSystem.instance.selectedCoord = nextSnapPoint
                                    moveCursorY(location: nextSnapPoint)
                                    moveCursorX(location: CGPoint(x: nextSnapPoint.x, y: sheetCursor.curXCursorLocation.y))
                                    
                                }/* else {
                                    if measure.isFull {
                                        if let measureCoord = GridSystem.instance.selectedMeasureCoord {
                                            self.moveCursorsToNextMeasure(measurePoints: measureCoord)
                                            //return
                                        }
                                    }
                                }*/
                            }
                            
                        }
                    } else {
                        moveCursorsToNearestSnapPoint(location: sheetCursor.curYCursorLocation)
                    }
                }
            } else {
                if let currentPoint = GridSystem.instance.selectedCoord {
                    
                    if let nextSnapPoint = GridSystem.instance.getLeftXSnapPoint(currentPoint: currentPoint) {
                    
                        if nextSnapPoint == currentPoint {
                            
                            moveCursorsToNearestSnapPoint(location: currentPoint)
                            
                        } else {
                            
                            GridSystem.instance.selectedCoord = nextSnapPoint
                            moveCursorY(location: nextSnapPoint)
                            moveCursorX(location: CGPoint(x: nextSnapPoint.x, y: sheetCursor.curXCursorLocation.y))
                            
                        }
                        
                    }
                }
            }
            
            for notation in self.selectedNotations {
                self.highlightNotation(notation)
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
                clefType: upperStaffMeasures[0].clef, measures:upperStaffMeasures)

        staffIndex += 1
        let _ = drawStaff(startX: lefRightPadding, startY: startY + staffSpace * staffIndex,
                clefType: lowerStaffMeasures[0].clef, measures:lowerStaffMeasures)

        if let height = measureHeight {
            drawStaffConnection(startX: lefRightPadding, startY: startPoint - height, height: height)
        }
    }
    
    // Draws a staff
    private func drawStaff(startX:CGFloat, startY:CGFloat, clefType:Clef, measures:[Measure]) -> CGFloat? {

        // Handles adding of clef based on parameter
        drawClefLabel(startX: startX, startY: startY, clefType: clefType)
        
        // Adjust initial space for clef and time signature
        let startMeasure:CGFloat = startX + 85

        // Track distance for each measure to be printed
        var distance:CGFloat = (endX-startMeasure)/CGFloat(measures.count)

        // Start drawing the measures
        var modStartX:CGFloat = startMeasure
        var measureLocation:GridSystem.MeasurePoints?

        for i in 0...measures.count-1 {
            
            var adjustKeyTimeSig:CGFloat = 0
            
            if i > 0 {
                adjustKeyTimeSig += 10
            }
            
            // START OF DRAWING KEY SIGNATURE
            
            if let staffList = composition?.staffList {
                for staff in staffList {
                    if let measureIndex = staff.measures.index(of: measures[i]) {
                        if measureIndex > 0 {
                            if staff.measures[measureIndex - 1].keySignature != staff.measures[measureIndex].keySignature {
                                let keyLabelWidth = drawKeySignature(startX: modStartX + adjustKeyTimeSig, startY: startY, keySignature: measures[i].keySignature)
                                adjustKeyTimeSig += keyLabelWidth
                            }
                        } else if measureIndex == 0 {
                            let keyLabelWidth = drawKeySignature(startX: modStartX + adjustKeyTimeSig, startY: startY, keySignature: measures[i].keySignature)
                            adjustKeyTimeSig += keyLabelWidth
                        }
                    }
                }
            }
            
            // END IF DRAWING KEY SIGNATURE
            
            var timeLabelWidth:CGFloat?
            
            if i > 0 {
                adjustKeyTimeSig += 20
            }
            
            if let staffList = composition?.staffList {
                for staff in staffList {
                    if let measureIndex = staff.measures.index(of: measures[i]) {
                        if measureIndex > 0 {
                            if staff.measures[measureIndex - 1].timeSignature != staff.measures[measureIndex].timeSignature {
                                timeLabelWidth = drawTimeLabel(startX: modStartX + adjustKeyTimeSig, startY: startY, timeSignature: measures[i].timeSignature)
                            }
                        } else if measureIndex == 0 {
                            timeLabelWidth = drawTimeLabel(startX: modStartX + adjustKeyTimeSig, startY: startY, timeSignature: measures[i].timeSignature)
                        }
                    }
                }
            }
            // END OF DRAWING TIME SIGNATURE
            
            if let timeLabelWidth = timeLabelWidth {
                modStartX = modStartX + timeLabelWidth
                distance = distance - timeLabelWidth
            }
            
            modStartX += adjustKeyTimeSig
            distance -= adjustKeyTimeSig
            
            // START OF DRAWING OF MEASURE
            measureLocation = drawMeasure(measure: measures[i], startX: modStartX, endX: modStartX+distance, startY: startY)
            
            if let measureLocation = measureLocation {
                GridSystem.instance.assignMeasureToPoints(measurePoints: measureLocation, measure: measures[i])
                GridSystem.instance.appendMeasurePointToLatestArray(measurePoints: measureLocation)
            }
            // END OF DRAWING OF MEASURE

            modStartX = modStartX + distance
        }
        
        if let measureLocation = measureLocation {
            return measureLocation.upperLeftPoint.y - measureLocation.lowerRightPoint.y
        } else {
            return nil
        }
    }
    
    private func drawKeySignature (startX:CGFloat, startY:CGFloat, keySignature:KeySignature) -> CGFloat {
        
        if keySignature == .c {
            return 0
        } else {
            
            let numberOfAccidentals = abs(keySignature.rawValue)
            let snapPointsForKeySig = GridSystem.instance.createSnapPointsForKeySig(initialX: startX, initialY: startY - (lineSpace*5.85), lineSpace: lineSpace)
            
            var space:CGFloat = 0
            
            for i in 0..<numberOfAccidentals {
                
                // sharps
                if keySignature.rawValue > 0 {
                    
                    let snapPointSequence = [1, 4, 0, 3, 6, 2, 5]
                        
                    let sharp = UIImage(named:"sharp")
                    let currentSnapPoint = snapPointsForKeySig[snapPointSequence[i]]
                    
                    let sharpView = UIImageView(frame: CGRect(x: currentSnapPoint.x + space, y: currentSnapPoint.y, width: 56/3, height: 150/3))
                    
                    sharpView.image = sharp
                    self.addSubview(sharpView)
                    
                    space += 15
                
                } else if keySignature.rawValue < 0 { // flats
                    
                    let snapPointSequence = [5, 2, 6, 3, 7, 4, 8]
                    
                    let flat = UIImage(named:"flat")
                    let currentSnapPoint = snapPointsForKeySig[snapPointSequence[i]]
                    
                    let flatView = UIImageView(frame: CGRect(x: currentSnapPoint.x + space, y: currentSnapPoint.y, width: 56/3, height: 150/3))
                    
                    flatView.image = flat
                    self.addSubview(flatView)
                    
                    space += 15
                    
                }
                
            }
            
            return space + 56/3
            
        }
        
        return 0
        
    }
    
    // Draws the clef and time before the staff
    private func drawTimeLabel(startX:CGFloat, startY:CGFloat, timeSignature:TimeSignature) -> CGFloat {
        
        let upperText = "\(timeSignature.beats)"
        let lowerText = "\(timeSignature.beatType)"
        
        // default width for 1 digit time signature
        var maxWidth:CGFloat = 32
        
        // adjust width for time signature based on number of digits
        if maxWidth * CGFloat(upperText.count) >= maxWidth * CGFloat(lowerText.count) {
            maxWidth = maxWidth * CGFloat(upperText.count)
        } else if maxWidth * CGFloat(lowerText.count) >= maxWidth * CGFloat(upperText.count) {
            maxWidth = maxWidth * CGFloat(lowerText.count)
        }
        
        let upperTimeSig = UILabel(frame: CGRect(x:startX ,y: startY - 127, width:maxWidth, height:96))
        let lowerTimeSig = UILabel(frame: CGRect(x:startX ,y: startY - 86, width:maxWidth, height:96))

        upperTimeSig.textAlignment = .center
        lowerTimeSig.textAlignment = .center
        
        var upperNumString = ""
        var lowerNumString = ""
        
        for char in upperText {
            if let singleNumber = Int(String(char)) {
                if let equivSymbol = getEquivalentNumberSymbol(n: singleNumber) {
                    upperNumString += equivSymbol
                }
            }
        }
        
        for char in lowerText {
            if let singleNumber = Int(String(char)) {
                if let equivSymbol = getEquivalentNumberSymbol(n: singleNumber) {
                    lowerNumString += equivSymbol
                }
            }
        }
        
        upperTimeSig.text = upperNumString
        lowerTimeSig.text = lowerNumString
        
        upperTimeSig.tag = TIME_SIGNATURES_TAG
        lowerTimeSig.tag = TIME_SIGNATURES_TAG
        
        upperTimeSig.font = UIFont(name: "Maestro", size: 80.0)
        lowerTimeSig.font = UIFont(name: "Maestro", size: 80.0)
        
        self.addSubview(upperTimeSig)
        self.addSubview(lowerTimeSig)
        
        return maxWidth
    }
    
    // this is for getting the Maestro font style of the time signature
    private func getEquivalentNumberSymbol(n: Int) -> String? {
        
        switch n {
            case 0:
                return ""
            case 1:
                return ""
            case 2:
                return ""
            case 3:
                return ""
            case 4:
                return ""
            case 5:
                return ""
            case 6:
                return ""
            case 7:
                return ""
            case 8:
                return ""
            case 9:
                return ""
            default:
            break
        }
        
        return nil
        
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
    private func drawMeasure(measure: Measure, startX:CGFloat, endX:CGFloat, startY:CGFloat) -> GridSystem.MeasurePoints {
        
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
            GridSystem.MeasurePoints(upperLeftPoint: CGPoint(x: startX, y: startY),
                                     lowerRightPoint: CGPoint(x: endX, y: startY-curSpace),
                                     upperLeftPointWithLedger: CGPoint(x: startX, y: startY+(lineSpace*3.5)),
                                     lowerRightPointWithLedger: CGPoint(x: endX, y: startY-curSpace-(lineSpace*3.5)))
        
        measureCoords.append(measureCoord)
        
        let snapPoints = GridSystem.instance.createSnapPoints(initialX: startX + initialNoteSpace, initialY: startY-curSpace-(lineSpace*3.5), clef: measure.clef, lineSpace: lineSpace)
        GridSystem.instance.assignSnapPointsToPoints(measurePoints: measureCoord, snapPoint: snapPoints)
        
        // CHOOSE FIRST MEASURE COORD AS DEFAULT
        if GridSystem.instance.selectedMeasureCoord == nil {
            GridSystem.instance.selectedMeasureCoord = measureCoord
            
            // the middle snap point
            GridSystem.instance.selectedCoord = snapPoints[11]
            
            moveCursorX(location: CGPoint(x: snapPoints[0].x, y: measureCoord.lowerRightPoint.y + cursorXOffsetY))
            moveCursorY(location: snapPoints[0])
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
        
        let adjustXToCenter = adjustToXCenter * initialNoteSpace

//        var points = snapPoints

        if measure.notationObjects.count > 0 {
            
            GridSystem.instance.clearAllSnapPointsFromMeasure(measurePoints: measureCoord)

            var notationSpace = measureCoord.width / CGFloat(measure.timeSignature.beats) // not still sure about this
            
            if measure.notationObjects.count < measure.timeSignature.beats {
                // TODO: LESSEN SPACE HERE
            } else if measure.notationObjects.count > measure.timeSignature.beats {
                notationSpace = measureCoord.width / CGFloat(measure.notationObjects.count)
            }
            
            var prevX:CGFloat?
            
            // add all notes existing in the measure
            for (index, note) in measure.notationObjects.enumerated() {

                if index == 0 {
                    
                    if note is Note {
                        note.screenCoordinates =
                            CGPoint(x: measureCoord.upperLeftPoint.x + initialNoteSpace,
                                    y: GridSystem.instance.getYFromPitch(notation: note, clef: measure.clef, snapPoints: snapPoints))
                    } else if note is Rest {
                        
                        if let height = note.image?.size.height {
                        
                            note.screenCoordinates =
                                CGPoint(x: measureCoord.upperLeftPoint.x + initialNoteSpace,
                                        y: (measureCoord.upperLeftPoint.y + measureCoord.lowerRightPoint.y) / 2 - (height/restHeightAlter/2))
                            
                        }
                    }
                    
                    let snapPointsRelativeToNotation = GridSystem.instance.createSnapPoints(
                        initialX: measureCoord.upperLeftPoint.x + initialNoteSpace + adjustXToCenter, initialY: measureCoord.lowerRightPoint.y-(lineSpace*3.5), clef: measure.clef, lineSpace: lineSpace)
                    
                    // snap points for added note
                    GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measureCoord,
                                                                  snapPoints: snapPointsRelativeToNotation)
                    
                    // assign snap point to added note
                    if note is Note {
                        GridSystem.instance.assignSnapPointToNotation(
                            snapPoint: CGPoint(x: measureCoord.upperLeftPoint.x + initialNoteSpace + adjustXToCenter, y: GridSystem.instance.getYFromPitch(notation: note, clef: measure.clef, snapPoints: snapPoints)),
                            notation: note)
                    } else if note is Rest {
                        for snapPoint in snapPointsRelativeToNotation {
                            GridSystem.instance.assignSnapPointToNotation(
                                snapPoint: snapPoint,
                                notation: note)
                        }
                    }
                    
                    // if measure is not full, add more snapping points right next to new note added
                    if !measure.isFull {
                        
                        let additionalSnapPoints = GridSystem.instance.createSnapPoints(
                            initialX: measureCoord.upperLeftPoint.x + initialNoteSpace + notationSpace + adjustXToCenter, initialY: measureCoord.lowerRightPoint.y-(lineSpace*3.5), clef: measure.clef, lineSpace: lineSpace)
                    
                        GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measureCoord,
                                                                      snapPoints: additionalSnapPoints)
                        
                        prevX = measureCoord.upperLeftPoint.x + initialNoteSpace + notationSpace + adjustXToCenter
                        
                    }
                    
                } else {
                    
                    if let prevNoteCoordinates =  measure.notationObjects[index - 1].screenCoordinates {
                    
                        
                        if note is Note {
                            note.screenCoordinates =
                                CGPoint(x: prevNoteCoordinates.x + notationSpace,
                                        y: GridSystem.instance.getYFromPitch(notation: note, clef: measure.clef, snapPoints: snapPoints))
                        }  else if note is Rest {
                            
                            if let height = note.image?.size.height {
                                
                                note.screenCoordinates =
                                    CGPoint(x: prevNoteCoordinates.x + notationSpace,
                                            y: (measureCoord.upperLeftPoint.y + measureCoord.lowerRightPoint.y) / 2 - (height/restHeightAlter/2))
                                
                            }
                        }
                        
                        if let prevX = prevX {
                            GridSystem.instance.removeRelativeXSnapPoints(measurePoints: measureCoord, relativeX: prevX)
                        }
                        
                        let snapPointsRelativeToNotation = GridSystem.instance.createSnapPoints(
                            initialX: prevNoteCoordinates.x + notationSpace + adjustXToCenter, initialY: measureCoord.lowerRightPoint.y-(lineSpace*3.5), clef: measure.clef, lineSpace: lineSpace)
                        
                        GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measureCoord,
                                                                      snapPoints: snapPointsRelativeToNotation)
                        
                        if note is Note {
                            GridSystem.instance.assignSnapPointToNotation(
                                snapPoint: CGPoint(x: prevNoteCoordinates.x + notationSpace + adjustXToCenter,
                                                   y: GridSystem.instance.getYFromPitch(notation: note, clef: measure.clef, snapPoints: snapPoints)),
                                notation: note)
                        } else if note is Rest {
                            for snapPoint in snapPointsRelativeToNotation {
                                GridSystem.instance.assignSnapPointToNotation(snapPoint: snapPoint, notation: note)
                            }
                        }
                        
                        // if measure is not full, add more snapping points right next to new note added
                        if !measure.isFull {
                            
                            let additionalSnapPoints = GridSystem.instance.createSnapPoints(
                                initialX: prevNoteCoordinates.x + notationSpace*2 + adjustXToCenter, initialY: measureCoord.lowerRightPoint.y-(lineSpace*3.5), clef: measure.clef, lineSpace: lineSpace)
                        
                            GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measureCoord,
                                                                          snapPoints: additionalSnapPoints)
                            
                            prevX = prevNoteCoordinates.x + notationSpace*2 + adjustXToCenter
                            
                        }
                        
                    }
                }
                
                if let noteCoordinates = note.screenCoordinates {
                    
                    drawLedgerLinesIfApplicable(measurePoints: measureCoord, upToLocation: noteCoordinates)
                    
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

        var notationImageView: UIImageView?
        
        if notation is Note {
            notationImageView = UIImageView(frame: CGRect(x: ((notation.screenCoordinates)?.x)! + noteXOffset, y: ((notation.screenCoordinates)?.y)! + noteYOffset, width: (notation.image?.size.width)! + noteWidthAlter, height: (notation.image?.size.height)! + noteHeightAlter))
        } else if notation is Rest {
            notationImageView = UIImageView(frame: CGRect(x: ((notation.screenCoordinates)?.x)! + noteXOffset, y: ((notation.screenCoordinates)?.y)! + restYOffset, width: (notation.image?.size.width)! / restWidthAlter, height: (notation.image?.size.height)! / restHeightAlter))
        }
        
        if let notationImageView = notationImageView {
            notationImageView.image = notation.image
        
            self.addSubview(notationImageView)
        }

        //self.assembleNoteForBeaming(notation: notation, stemHeight: 100)
    }
    
    func onArrowKeyPressed(params: Parameters) {
        let direction:ArrowKey = params.get(key: KeyNames.ARROW_KEY_DIRECTION) as! ArrowKey
        var nextPoint:CGPoint = sheetCursor.curYCursorLocation
        
        if direction == ArrowKey.up {
            
            if !self.selectedNotations.isEmpty {
                for notation in self.selectedNotations {
                    if let note = notation as? Note {
                        note.transposeUp()
                    }
                }
                self.updateMeasureDraw()
                return;
            }
            
            if let point = GridSystem.instance.getUpYSnapPoint(currentPoint: sheetCursor.curYCursorLocation) {
                nextPoint = point
            } else {
                return
            }
            
        } else if direction == ArrowKey.down {
            
            if !self.selectedNotations.isEmpty {
                for notation in self.selectedNotations {
                    if let note = notation as? Note {
                        note.transposeDown()
                    }
                }
                self.updateMeasureDraw()
                return;
            }
            
            if let point = GridSystem.instance.getDownYSnapPoint(currentPoint: sheetCursor.curYCursorLocation) {
                nextPoint = point
            } else {
                return
            }
            
        } else if direction == ArrowKey.left {
            
            if let point = GridSystem.instance.getLeftXSnapPoint(currentPoint: sheetCursor.curYCursorLocation) {
                nextPoint = point
            } else {
                return
            }
            
        } else if direction == ArrowKey.right {
            
            if let point = GridSystem.instance.getRightXSnapPoint(currentPoint: sheetCursor.curYCursorLocation) {
                nextPoint = point
            } else {
                return
            }
            
        }
        
        // go to next measure with the same clef
        if nextPoint == sheetCursor.curYCursorLocation {
            if let measurePoints = GridSystem.instance.selectedMeasureCoord {
                
                if direction == ArrowKey.left {
                    moveCursorsToPreviousMeasure(measurePoints: measurePoints)
                } else if direction == ArrowKey.right {
                    moveCursorsToNextMeasure(measurePoints: measurePoints)
                }
            }
        } else {
            sheetCursor.curXCursorLocation.x = nextPoint.x
            sheetCursor.curYCursorLocation.x = nextPoint.x
            
            moveCursorX(location: sheetCursor.curXCursorLocation)
            moveCursorY(location: nextPoint)
        }
        
        
        GridSystem.instance.selectedCoord = sheetCursor.curYCursorLocation
        
        /*let xLocString = "CURSOR X LOCATION: (" + String(describing: curXCursorLocation.x) + ", " + String(describing: curXCursorLocation.y) + ")"
        let yLocString = "CURSOR Y LOCATION: (" + String(describing: curYCursorLocation.x) + ", " + String(describing: curYCursorLocation.y) + ")"
        
        print(xLocString)
        print(yLocString)*/
    }
    
    public func moveCursorY(location: CGPoint) {
        sheetCursor.moveCursorY(location: location)
        
        if let measurePoints = GridSystem.instance.selectedMeasureCoord {
            sheetCursor.showLedgerLinesGuide(measurePoints: measurePoints, upToLocation: location, lineSpace: lineSpace)
        }
        
        if let notation = GridSystem.instance.getNotationFromSnapPoint(snapPoint: location) {
            hoveredNotation = notation
            if let measure = notation.measure {
                measure.updateInvalidNotes(invalidNotes: measure.getInvalidNotes(without: notation))
            }
        } else {
            hoveredNotation = nil
        }

    }
    
    private func drawLedgerLinesIfApplicable (measurePoints: GridSystem.MeasurePoints,upToLocation: CGPoint) {
            
        if upToLocation.y < measurePoints.lowerRightPoint.y {
            
            var currentPoint = CGPoint(x:upToLocation.x, y: measurePoints.lowerRightPoint.y - lineSpace)
            
            while currentPoint.y >= upToLocation.y-1.5 {
                let _ = drawLine(start: CGPoint(x: upToLocation.x, y: currentPoint.y),
                                 end: CGPoint(x: upToLocation.x + 45, y: currentPoint.y), thickness: 4)
                
                currentPoint = CGPoint(x:currentPoint.x, y: currentPoint.y - lineSpace)
            }
            
        } else if upToLocation.y > measurePoints.upperLeftPoint.y {
            
            var currentPoint = CGPoint(x:upToLocation.x, y: measurePoints.upperLeftPoint.y + lineSpace)
            
            while currentPoint.y <= upToLocation.y {
                let _ = drawLine(start: CGPoint(x: upToLocation.x, y: currentPoint.y),
                                 end: CGPoint(x: upToLocation.x + 45, y: currentPoint.y), thickness: 4)
                
                currentPoint = CGPoint(x:currentPoint.x, y: currentPoint.y + lineSpace)
            }
            
        }

    }
    
    public func moveCursorX(location: CGPoint) {
        sheetCursor.moveCursorX(location: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
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
        moveCursorsToNearestSnapPoint(location: location)
    }
    
    private func moveCursorsToNearestSnapPoint (location:CGPoint) {
        if let measureCoord = GridSystem.instance.selectedMeasureCoord {
            
            if let snapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: measureCoord) {
                
                var closestPoint: CGPoint = snapPoints[0]
                
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
                
                let newXCurLocation = CGPoint(x: closestPoint.x, y: sheetCursor.curXCursorLocation.y)
                
                moveCursorX(location: newXCurLocation)
                moveCursorY(location: closestPoint)
                
                GridSystem.instance.selectedCoord = closestPoint
            }
            
            GridSystem.instance.currentStaffIndex =
                GridSystem.instance.getStaffIndexFromMeasurePoint(measurePoints: measureCoord)
        }
    }
    
    private func remapCurrentMeasure (location:CGPoint) {
        
        for measureCoord in measureCoords {
            let r:CGRect = CGRect(x: measureCoord.upperLeftPointWithLedger.x, y: measureCoord.upperLeftPointWithLedger.y,
                                  width: measureCoord.width,
                                  height: measureCoord.heightWithLedger)
            
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
                
                moveCursorX(location: CGPoint(x: sheetCursor.curYCursorLocation.x, y: firstMeasureCoord.lowerRightPoint.y + cursorXOffsetY))
                
            }
        }

    }

    func updateMeasureDraw () {
        startY = 200 + sheetYOffset
        staffIndex = -1

        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        measureCoords.removeAll()
        GridSystem.instance.clearNotationSnapPointMap()

        self.setNeedsDisplay()

        print("finished updating the view")
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let locationOfBeganTap = sender.location(in: self)
            self.highlightRect.highlightingStartPoint = locationOfBeganTap
            self.highlightRect.highlightingEndPoint = locationOfBeganTap
            
            /*if let measure = self.getMeasureFromPoint(point: locationOfBeganTap) {
                print("found measure: \(measure)")
                self.selectedClef = measure.clef
            }*/
            
        } else if sender.state == UIGestureRecognizerState.ended {
            self.checkPointsInRect()
            self.highlightRect.highlightingEndPoint = nil
        } else {
            let location = sender.location(in: self)
//            let previousLocation = self.highlightRect.highlightingEndPoint
            self.highlightRect.highlightingEndPoint = location
            
            /*if self.selectedClef == nil {
                if let measure = self.getMeasureFromPoint(point: location) {
                    print("found measure: \(measure)")
                    self.selectedClef = measure.clef
                }
            } else if let clef = self.selectedClef {
                print("My clef: \(clef)")
                if self.getMeasureFromPoint(point: location)?.clef != clef {
                    print("Not same clef")
                    
                    // TODO: Fix this! Still buggy
                    self.highlightRect.highlightingEndPoint!.y = previousLocation!.y
                    //self.selectedClef = measure.clef
                }
            }*/
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
                        self.highlightNotation(notation)
                        
                        
                    }
                }
            }
        }
    }
    
    func highlightNotation(_ notation: MusicNotation) {
        let noteImageView = UIImageView(frame: CGRect(x: ((notation.screenCoordinates)?.x)! + noteXOffset, y: ((notation.screenCoordinates)?.y)! + noteYOffset, width: (notation.image?.size.width)! + noteWidthAlter, height: (notation.image?.size.height)! + noteHeightAlter))
        
        noteImageView.image = notation.image
        noteImageView.image = noteImageView.image!.withRenderingMode(.alwaysTemplate)
        noteImageView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        noteImageView.tag = HIGHLIGHTED_NOTES_TAG
        
        self.addSubview(noteImageView)
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
            if let prevSnapIndex = prevSnapPoints?.index(where: {$0.y == sheetCursor.curYCursorLocation.y}) {
                
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
                    
                    if indexJump < measureCoords.count {
                    
                        if let firstMeasurePoints = GridSystem.instance.getFirstMeasurePointFromStaff(measurePoints: measureCoords[indexJump]) {
                        
                            moveCursorX(location: CGPoint(x: newSnapPoints[prevSnapIndex].x,
                                                          y: firstMeasurePoints.lowerRightPoint.y + cursorXOffsetY))
                            moveCursorY(location: newSnapPoints[prevSnapIndex])
                            
                            scrollMusicSheetToY(y: measureCoords[indexJump].lowerRightPoint.y - 140)
                        }
                        
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

                if let prevSnapIndex = prevSnapPoints.index(where: {$0.y == sheetCursor.curYCursorLocation.y}) {
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
                        
                        let newCoord = newSnapPoints[(newSnapPoints.count-1) - (GridSystem.instance.NUMBER_OF_SNAPPOINTS_PER_COLUMN - prevSnapIndex)]
                        
                        print(newCoord)
                        
                        GridSystem.instance.selectedCoord = newCoord
                        
                        // get first measure points of the
                        if let firstMeasurePoints = GridSystem.instance.getFirstMeasurePointFromStaff(measurePoints: measureCoords[indexJump]) {
                            
                            moveCursorX(location: CGPoint(x: newCoord.x,
                                                          y: firstMeasurePoints.lowerRightPoint.y + cursorXOffsetY))
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

    public func drawLine(start: CGPoint, end: CGPoint, thickness: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()

        path.lineWidth = thickness
        path.move(to: start)
        path.addLine(to: end)
        path.stroke()
        
        return path
    }
    
    // BEAMS group of notes
    public func beamNotes(notations: [MusicNotation]) {
        var curNotesToBeam = [MusicNotation]()
        
        if notations.count > 1 {
            for notation in notations {
                if !(notation is Rest) {
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
                } else {
                    addMusicNotation(notation: notation)
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

        var stemHeight: CGFloat = 60

        for notation in notations {
            if let note = notation as? Note {
                if note.isUpwards {
                    upCount = upCount + 1
                } else {
                    downCount = downCount + 1
                }
            }

            if notation.type == RestNoteType.sixtyFourth {
                stemHeight = 80
            }
        }

        // check whether there are more upward notes and vice versa
        if upCount > downCount {
            let highestNote = getLowestOrHighestNote(highest: true, notations: notations)
            let highestY: CGFloat = highestNote.screenCoordinates!.y - stemHeight - 4
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
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4 ), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                            } else if curSameNotes[0].type == RestNoteType.thirtySecond {
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4 ), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                            } else if curSameNotes[0].type == RestNoteType.sixtyFourth {
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4 ), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), thickness: lineSpace / 2)
                            }
                        } else if curSameNotes.count == 1 {
                            // add flag of curSameNotes[0]
                            // add flag of notation
                            if curSameNotes[0].type == RestNoteType.sixteenth {
                                if curSameNotes[0] === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                }
                            } else if curSameNotes[0].type == RestNoteType.thirtySecond {
                                if curSameNotes[0] === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                                }
                            } else if curSameNotes[0].type == RestNoteType.sixtyFourth {
                                if curSameNotes[0] === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), thickness: lineSpace / 2)
                                }
                            }

                            if notation.type == RestNoteType.sixteenth {
                                if notation === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                }

                            } else if notation.type == RestNoteType.thirtySecond {
                                if notation === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                                }

                            } else if notation.type == RestNoteType.sixtyFourth {
                                if notation === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), thickness: lineSpace / 2)
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
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                } else if curSameNotes[0].type == RestNoteType.thirtySecond {
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                } else if curSameNotes[0].type == RestNoteType.sixtyFourth {
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), thickness: lineSpace / 2)
                }
            } else if curSameNotes.count == 1 {
                // add appripriate flag of curSameNotes[0]
                if curSameNotes[0].type == RestNoteType.sixteenth {
                    if curSameNotes[0] === notations[notations.count - 1] {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                    } else {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                    }
                } else if curSameNotes[0].type == RestNoteType.thirtySecond {
                    if curSameNotes[0] === notations[notations.count - 1] {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                    } else {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                    }
                } else if curSameNotes[0].type == RestNoteType.sixtyFourth {
                    if curSameNotes[0] === notations[notations.count - 1] {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 - 22, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), thickness: lineSpace / 2)
                    } else {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace + lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace + lineSpace / 2), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 23.9 + 24, y: highestY + lineSpace * 1.5 + lineSpace * 0.75), thickness: lineSpace / 2)
                    }
                }
            }

            // draws the beam based on highest note
            let _ = self.drawLine(start: CGPoint(x: startX, y: highestY), end: CGPoint(x: endX, y: highestY), thickness: lineSpace / 2)
        } else {
            let lowestNote = getLowestOrHighestNote(highest: false, notations: notations)
            let lowestY: CGFloat = lowestNote.screenCoordinates!.y + stemHeight + 5
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
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                            } else if curSameNotes[0].type == RestNoteType.thirtySecond {
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                            } else if curSameNotes[0].type == RestNoteType.sixtyFourth {
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                                let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), thickness: lineSpace / 2)
                            }
                        } else if curSameNotes.count == 1 {
                            // add flag of curSameNotes[0]
                            // add flag of notation
                            if curSameNotes[0].type == RestNoteType.sixteenth {
                                if curSameNotes[0] === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                }
                            } else if curSameNotes[0].type == RestNoteType.thirtySecond {
                                if curSameNotes[0] === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                                }
                            } else if curSameNotes[0].type == RestNoteType.sixtyFourth {
                                if curSameNotes[0] === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), thickness: lineSpace / 2)
                                }
                            }

                            if notation.type == RestNoteType.sixteenth {
                                if notation === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                }
                            } else if notation.type == RestNoteType.thirtySecond {
                                if notation === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                                }
                            } else if notation.type == RestNoteType.sixtyFourth {
                                if notation === notations[notations.count - 1] {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), thickness: lineSpace / 2)
                                } else {
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                                    let _ = self.drawLine(start: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), end: CGPoint(x: notation.screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), thickness: lineSpace / 2)
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
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                } else if curSameNotes[0].type == RestNoteType.thirtySecond {
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                } else if curSameNotes[0].type == RestNoteType.sixtyFourth {
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                    let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), end: CGPoint(x: curSameNotes[curSameNotes.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), thickness: lineSpace / 2)
                }
            } else if curSameNotes.count == 1 {
                // add appripriate flag of curSameNotes[0]
                if curSameNotes[0].type == RestNoteType.sixteenth {
                    if curSameNotes[0] === notations[notations.count - 1] {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                    } else {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                    }
                } else if curSameNotes[0].type == RestNoteType.thirtySecond {
                    if curSameNotes[0] === notations[notations.count - 1] {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                    } else {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                    }
                } else if curSameNotes[0].type == RestNoteType.sixtyFourth {
                    if curSameNotes[0] === notations[notations.count - 1] {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 - 24, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), thickness: lineSpace / 2)
                    } else {
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace / 2 - lineSpace / 4), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace / 2 - lineSpace / 4), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace - lineSpace / 2), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace - lineSpace / 2), thickness: lineSpace / 2)
                        let _ = self.drawLine(start: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), end: CGPoint(x: curSameNotes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2 + 22, y: lowestY - lineSpace * 1.5 - lineSpace * 0.75), thickness: lineSpace / 2)
                    }
                }
            }

            // draws the beam based on lowest note
            let _ = self.drawLine(start: CGPoint(x: startX, y: lowestY), end: CGPoint(x: endX, y: lowestY), thickness: lineSpace / 2)
        }
    }

    public func assembleNoteForBeaming(notation: MusicNotation, stemHeight: CGFloat, isUpwards: Bool) {
        let noteHead = UIImage(named: "quarter-head")

        var notationImageView: UIImageView

        let noteX: CGFloat = notation.screenCoordinates!.x + noteXOffset
        let noteY: CGFloat = notation.screenCoordinates!.y + noteYOffset

        let noteWidth: CGFloat = noteHead!.size.width + noteWidthAlter
        let noteHeight: CGFloat = noteHead!.size.height + noteHeightAlter

        notationImageView = UIImageView(frame: CGRect(x: noteX, y: noteY, width: noteWidth, height: noteHeight))

        notationImageView.image = noteHead

        self.addSubview(notationImageView)

        if isUpwards {
            let _ = self.drawLine(start: CGPoint(x: noteX + 24.9, y: noteY - noteYOffset - 4), end: CGPoint(x: noteX + 24.9, y: noteY - noteYOffset - stemHeight - 4), thickness: 2.3)
            //drawLine(start: CGPoint(x: noteX + 23.9, y: noteY - noteYOffset - stemHeight + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: noteX + 23.9 + 22, y: noteY - noteYOffset - stemHeight + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
        } else {
            let _ = self.drawLine(start: CGPoint(x: noteX + 1.5, y: noteY - noteYOffset + 3), end: CGPoint(x: noteX + 1.5, y: noteY - noteYOffset + stemHeight + 3), thickness: 2.3)
            //drawLine(start: CGPoint(x: noteX + 0.5, y: noteY - noteYOffset + stemHeight - lineSpace / 2 + lineSpace / 4), end: CGPoint(x: noteX + 0.5 + 22, y: noteY - noteYOffset + stemHeight - lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
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

    public func copy() {
        print("Copy")
        Clipboard.instance.copy(self.selectedNotations)
    }

    public func cut() {
        print("Cut")
        Clipboard.instance.cut(self.selectedNotations)
        self.selectedNotations.removeAll()
        self.updateMeasureDraw()
        
    }

    public func paste() {
        print("Paste")
        var measures = [Measure]()
        if !self.selectedNotations.isEmpty {
            for notation in self.selectedNotations {
                if let measure = notation.measure {
                    if !measures.contains(measure) {
                        measures.append(measure)
                    }
                }
            }
            
            let startMeasure = measures[0]
            let firstNotation = self.selectedNotations[0]
            if let startIndex = startMeasure.notationObjects.index(of: firstNotation) {
                Clipboard.instance.paste(measures: measures, at: startIndex)
            }
            
        } else if let selectedMeasure = GridSystem.instance.getCurrentMeasure() {
            if let staves = self.composition?.staffList {
                for staff in staves {
                    if let startIndex = staff.measures.index(of: selectedMeasure) {
                        measures = Array(staff.measures[startIndex...])
                    }
                }
            }
            
            let startMeasure = measures[0]
            if let hovered = self.hoveredNotation {
                if let startIndex = startMeasure.notationObjects.index(of: hovered) {
                    Clipboard.instance.paste(measures: measures, at: startIndex)
                }
            } else {
                Clipboard.instance.paste(measures: measures, at: startMeasure.notationObjects.count)
            }
        }
        
        
        
        self.updateMeasureDraw()
        
        //Clipboard.instance.paste(measures: <#T##[Measure]#>, noteIndex: &<#T##Int#>)
    }

    public func editTimeSig(params: Parameters) {
        let newMeasure:Measure = params.get(key: KeyNames.NEW_MEASURE) as! Measure
        let oldMeasure:Measure = params.get(key: KeyNames.OLD_MEASURE) as! Measure
        let newMaxBeatValue: Float = newMeasure.timeSignature.getMaxBeatValue()

        var oldTimeSig = TimeSignature()
        oldTimeSig.beats = oldMeasure.timeSignature.beats
        oldTimeSig.beatType = oldMeasure.timeSignature.beatType

        if let index = searchMeasureIndex(measure: oldMeasure) {
            if let staffs = composition?.staffList {
                for staff in staffs {
                    for i in index...staff.measures.count-1 {
                        if sameTimeSignature(t1: staff.measures[i].timeSignature, t2: oldTimeSig) {
                            let curMeasure = staff.measures[i]

                            while newMaxBeatValue < curMeasure.getTotalBeats() {
                                curMeasure.deleteInMeasure(curMeasure.notationObjects[curMeasure.notationObjects.count - 1])
                            }

                            staff.measures[i].timeSignature = newMeasure.timeSignature
                        }
                    }
                }
            }
        }
        
        moveCursorsToNearestSnapPoint(location: sheetCursor.curYCursorLocation)
    }

    public func editKeySig(params: Parameters) {
        let newMeasure:Measure = params.get(key: KeyNames.NEW_MEASURE) as! Measure
        let oldMeasure:Measure = params.get(key: KeyNames.OLD_MEASURE) as! Measure

        var oldKeySignature = KeySignature(rawValue: 0)
        oldKeySignature = oldMeasure.keySignature

        if let index = searchMeasureIndex(measure: oldMeasure) {
            if let staffs = composition?.staffList {
                for staff in staffs {
                    for i in index...staff.measures.count-1 {
                        if staff.measures[i].keySignature == oldKeySignature {
                            print(staff.measures[i].keySignature.toString())
                            staff.measures[i].keySignature = newMeasure.keySignature
                            print(staff.measures[i].keySignature.toString())
                        }
                    }
                }
            }
        }
    }

    public func searchMeasureIndex(measure: Measure) -> Int? {
        if let staffs = composition?.staffList {
            for staff in staffs {
                if let index = staff.measures.index(of: measure) {
                    return index
                }
            }
        }

        return nil
    }
    
    public func titleChanged(params: Parameters) {
        print("here")
        if let composition = self.composition {
            composition.compositionInfo.name = params.get(key: KeyNames.NEW_TITLE, defaultValue: "Untitled Composition")
        }
    }

    public func naturalize() {
        if !self.selectedNotations.isEmpty {
            for note in self.selectedNotations {
                if note is Note {
                    let curNote = note as! Note
                    curNote.accidental = .natural
                }
            }
        } else if let hovered = self.hoveredNotation {
            let curNote = hovered as! Note
            curNote.accidental = .natural
        }
    }

    public func flat() {
        if !self.selectedNotations.isEmpty {
            for note in self.selectedNotations {
                if note is Note {
                    let curNote = note as! Note
                    curNote.accidental = .flat
                }
            }
        } else if let hovered = self.hoveredNotation {
            let curNote = hovered as! Note
            curNote.accidental = .flat
        }
    }

    public func sharp() {
        if !self.selectedNotations.isEmpty {
            for note in self.selectedNotations {
                if note is Note {
                    let curNote = note as! Note
                    curNote.accidental = .sharp
                }
            }
        } else if let hovered = self.hoveredNotation {
            let curNote = hovered as! Note
            curNote.accidental = .sharp
        }
    }

    public func dsharp() {
        if !self.selectedNotations.isEmpty {
            for note in self.selectedNotations {
                if note is Note {
                    let curNote = note as! Note
                    curNote.accidental = .doubleSharp
                }
            }
        } else if let hovered = self.hoveredNotation {
            let curNote = hovered as! Note
            curNote.accidental = .doubleSharp
        }
    }

}
