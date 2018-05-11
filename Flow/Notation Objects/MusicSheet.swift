//
//  MusicSheet.swift
//  Flow
//
//  Created by Vince on 02/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

enum TranspositionDirection {
    case up, down
}

class MusicSheet: UIView {

    private let HIGHLIGHTED_NOTES_TAG = 2500
    private let TIME_SIGNATURES_TAG = 2501

    private let sheetYOffset:CGFloat = 20
    private let lineSpace:CGFloat = 20 // Spaces between lines in staff
    private let staffSpace:CGFloat = 260 // Spaces between staff
    private let lefRightPadding:CGFloat = 100 // Left and right padding of a staff
    private var startY:CGFloat = 200
    private var staffIndex:CGFloat = -1
    private var movingStartX: CGFloat = 0
    private var distance: CGFloat = 450
    private var clefWidth: CGFloat = 58.2

    private let noteXOffset: CGFloat = 10
    private let noteYOffset: CGFloat = -93
    private let noteWidthAlter: CGFloat = -3
    private let noteHeightAlter: CGFloat = -3

    private let restYOffset: CGFloat = -0.5
    private let wholeRestYOffset: CGFloat = 8
    private let halfRestYOffset: CGFloat = -5
    private let restWidthAlter: CGFloat = 1.7
    private let restHeightAlter: CGFloat = 1.7
    
    private let accidentalXOffset: CGFloat = -12
    private let sharpAccidentalYOffset: CGFloat = -26
    private let flatAccidentalYOffset: CGFloat = -35
    private let naturalAccidentalYOffset: CGFloat = -26
    private let doubleSharpAccidentalYOffset: CGFloat = -10

    private let initialNoteSpace: CGFloat = 10
    private let adjustToXCenter: CGFloat = 1.3

    private let NUM_MEASURES_PER_STAFF = 1

    // used for connecting a grand staff
    private var measureXDivs = Set<CGFloat>()

    // used for tracking coordinates of measures
    private var measureCoords = [GridSystem.MeasurePoints]()
    private var gMeasurePoints = [GridSystem.MeasurePoints]()
    private var fMeasurePoints = [GridSystem.MeasurePoints]()

    private var curLayers = [CALayer]()

    private let highlightRect = HighlightRect()
    public let sheetCursor = SheetCursor()
    private let cursorXOffsetY:CGFloat = -95 // distance of starting y from measure
    
    private let playbackHighlightRect = CAShapeLayer()
    private var playbackScrollLock = false
    
    public var composition: Composition?
    public var hoveredNotation: MusicNotation? {
        didSet {
            checkHighlightAccidentalButton()

            while let highlightView = self.viewWithTag(HIGHLIGHTED_NOTES_TAG) {
                highlightView.removeFromSuperview()
            }

            if let notation = hoveredNotation{
                if let measure = notation.measure {
                    measure.updateInvalidNotes(invalidNotes: measure.getInvalidNotes(without: notation))
                }

                /*if notation is Note {
                    EventBroadcaster.instance.postEvent(event: EventNames.ENABLE_ACCIDENTALS)
                } else {
                    EventBroadcaster.instance.postEvent(event: EventNames.DISABLE_ACCIDENTALS)
                }*/

                self.highlightNotation(notation, true)
            } else {
                //EventBroadcaster.instance.postEvent(event: EventNames.REMOVE_ACCIDENTAL_HIGHLIGHT)
                //disable accidentals
                //EventBroadcaster.instance.postEvent(event: EventNames.DISABLE_ACCIDENTALS)
            }
        }
    }

    private var curScale: CGFloat = 1.0
    var originalCenter:CGPoint?

    var isZooming = false

    var playBackTimer = Timer()

    private var endX: CGFloat = 0
    
    private var visibleLedgerLines = [UIBezierPath]()

    public var selectedNotations: [MusicNotation] = [] {
        didSet {
            checkHighlightAccidentalButton()
            print("SELECTED NOTES COUNT: " + String(selectedNotations.count))
            if selectedNotations.count == 0 {
                EventBroadcaster.instance.postEvent(event: EventNames.HIDE_TRANSPOSE_KEYS)
                if let measureCoord = GridSystem.instance.selectedMeasureCoord {
                    if let newMeasure = GridSystem.instance.getMeasureFromPoints(measurePoints: measureCoord) {
                        let params:Parameters = Parameters()
                        params.put(key: KeyNames.NEW_MEASURE, value: newMeasure)

                        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_SWITCHED, params: params)
                        //EventBroadcaster.instance.postEvent(event: EventNames.DISABLE_ACCIDENTALS)
                    }
                }

                //EventBroadcaster.instance.postEvent(event: EventNames.DISABLE_ACCIDENTALS)
            } else {
                selectedNotes()

                let params = Parameters()

                print("NANI")

                if let coord = selectedNotations.last?.screenCoordinates {
                    print("NANI2")
                    params.put(key: KeyNames.TRANSPOSE_KEYS_COORD, value: coord)
                    EventBroadcaster.instance.postEvent(event: EventNames.SHOW_TRANSPOSE_KEYS, params: params)
                }

                if selectedNotations.count > 1 {
                    let params = Parameters()

                    if allNotes(notations: selectedNotations) {
                        params.put(key: KeyNames.RI_TOGGLE, value: false)
                        EventBroadcaster.instance.postEvent(event: EventNames.TOGGLE_RI_VIEW, params: params)
                    } else {
                        params.put(key: KeyNames.RI_TOGGLE, value: true)
                        EventBroadcaster.instance.postEvent(event: EventNames.TOGGLE_RI_VIEW, params: params)
                    }
                } else {
                    let params = Parameters()
                    params.put(key: KeyNames.RI_TOGGLE, value: true)
                    EventBroadcaster.instance.postEvent(event: EventNames.TOGGLE_RI_VIEW, params: params)
                }
                //EventBroadcaster.instance.postEvent(event: EventNames.ENABLE_ACCIDENTALS)
            }
        }
    }

    public var selectedClef: Clef?
    
    var transpositions = 0
    private var initialPitches = [Pitch]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func allRests(notations: [MusicNotation]) -> Bool {
        for notation in notations {
            if notation is Note {
                return false
            }
        }

        return true
    }

    func checkHighlightAccidentalButton() {
        var naturalCount = 0
        var sharpCount = 0
        var flatCount = 0
        var dSharpCount = 0

        let params = Parameters()

        if !self.selectedNotations.isEmpty {
            if self.hoveredNotation != nil {
                EventBroadcaster.instance.postEvent(event: EventNames.REMOVE_ACCIDENTAL_HIGHLIGHT)
            }

            for notation in self.selectedNotations {
                if let note = notation as? Note {
                    if note.accidental == .natural {
                        naturalCount += 1
                    } else if note.accidental == .sharp {
                        sharpCount += 1
                    } else if note.accidental == .flat {
                        flatCount += 1
                    } else if note.accidental == .doubleSharp {
                        dSharpCount += 1
                    }
                }
            }

            if naturalCount == self.selectedNotations.count {
                params.put(key: KeyNames.ACCIDENTAL, value: Accidental.natural)
                EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, params: params)
            } else if sharpCount == self.selectedNotations.count {
                params.put(key: KeyNames.ACCIDENTAL, value: Accidental.sharp)
                EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, params: params)
            } else if flatCount == self.selectedNotations.count {
                params.put(key: KeyNames.ACCIDENTAL, value: Accidental.flat)
                EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, params: params)
            } else if dSharpCount == self.selectedNotations.count {
                params.put(key: KeyNames.ACCIDENTAL, value: Accidental.doubleSharp)
                EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, params: params)
            } else {
                EventBroadcaster.instance.postEvent(event: EventNames.REMOVE_ACCIDENTAL_HIGHLIGHT)
            }
        } else {
            print("EMPTYYY")
            EventBroadcaster.instance.postEvent(event: EventNames.REMOVE_ACCIDENTAL_HIGHLIGHT)
        }

        if self.selectedNotations.isEmpty {
            if let hoveredNote = self.hoveredNotation as? Note {
                if hoveredNote.accidental == .natural {
                    params.put(key: KeyNames.ACCIDENTAL, value: Accidental.natural)
                    EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, params: params)
                } else if hoveredNote.accidental == .sharp {
                    params.put(key: KeyNames.ACCIDENTAL, value: Accidental.sharp)
                    EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, params: params)
                } else if hoveredNote.accidental == .flat {
                    params.put(key: KeyNames.ACCIDENTAL, value: Accidental.flat)
                    EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, params: params)
                } else if hoveredNote.accidental == .doubleSharp {
                    params.put(key: KeyNames.ACCIDENTAL, value: Accidental.doubleSharp)
                    EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, params: params)
                } else {
                    EventBroadcaster.instance.postEvent(event: EventNames.REMOVE_ACCIDENTAL_HIGHLIGHT)
                }
            } else {
                EventBroadcaster.instance.postEvent(event: EventNames.REMOVE_ACCIDENTAL_HIGHLIGHT)
            }
        }
    }

    private func setup() {

        //self.addSubview(KeyboardView.instance.keyboard)

        while let highlightView = self.viewWithTag(HIGHLIGHTED_NOTES_TAG) {
            highlightView.removeFromSuperview()
        }

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

        EventBroadcaster.instance.removeObserver(event: EventNames.PLAY_KEY_PRESSED, observer: Observer(id: "MusicSheet.play", function: self.play))
        EventBroadcaster.instance.addObserver(event: EventNames.PLAY_KEY_PRESSED, observer: Observer(id: "MusicSheet.play", function: self.play))

        /*EventBroadcaster.instance.removeObservers(event: EventNames.EDIT_TIME_SIG)
        EventBroadcaster.instance.addObserver(event: EventNames.EDIT_TIME_SIG, observer: Observer(id: "MusicSheet.editTimeSig", function: self.editTimeSig))

        EventBroadcaster.instance.removeObservers(event: EventNames.EDIT_KEY_SIG)
        EventBroadcaster.instance.addObserver(event: EventNames.EDIT_KEY_SIG, observer: Observer(id: "MusicSheet.editKeySig", function: self.editKeySig))*/

        EventBroadcaster.instance.removeObservers(event: EventNames.EDIT_SIGNATURE)
        EventBroadcaster.instance.addObserver(event: EventNames.EDIT_SIGNATURE, observer: Observer(id: "MusicSheet.editSignature", function: self.editSignature))

        
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

        EventBroadcaster.instance.removeObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "MusicSheet.enableInteraction", function: self.enableInteraction))
        EventBroadcaster.instance.addObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "MusicSheet.enableInteraction", function: self.enableInteraction))

        EventBroadcaster.instance.removeObservers(event: EventNames.HIGHLIGHT_MEASURE)
        EventBroadcaster.instance.addObserver(event: EventNames.HIGHLIGHT_MEASURE, observer: Observer(id: "MusicSheet.highlightParallelMeasures", function: self.highlightParallelMeasures))

        EventBroadcaster.instance.removeObserver(event: EventNames.TRANSPOSE_UP, observer: Observer(id: "MusicSheet.transposeUp", function: self.transposeUp))
        EventBroadcaster.instance.addObserver(event: EventNames.TRANSPOSE_UP, observer: Observer(id: "MusicSheet.transposeUp", function: self.transposeUp))

        EventBroadcaster.instance.removeObserver(event: EventNames.TRANSPOSE_DOWN, observer: Observer(id: "MusicSheet.transposeDown", function: self.transposeDown))
        EventBroadcaster.instance.addObserver(event: EventNames.TRANSPOSE_DOWN, observer: Observer(id: "MusicSheet.transposeDown", function: self.transposeDown))

        EventBroadcaster.instance.removeObserver(event: EventNames.INVERSE, observer: Observer(id: "MusicSheet.inverseSelected", function: self.inverseSelected))
        EventBroadcaster.instance.addObserver(event: EventNames.INVERSE, observer: Observer(id: "MusicSheet.inverseSelected", function: self.inverseSelected))

        EventBroadcaster.instance.removeObserver(event: EventNames.RETROGRADE, observer: Observer(id: "MusicSheet.retrogradeSelected", function: self.retrogradeSelected))
        EventBroadcaster.instance.addObserver(event: EventNames.RETROGRADE, observer: Observer(id: "MusicSheet.retrogradeSelected", function: self.retrogradeSelected))

        // Set up pan gesture for dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        panGesture.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGesture)
    }

    func onCompositionLoad (params: Parameters) {
        //composition = params.get(key: KeyNames.COMPOSITION) as? Composition
    }

    override func draw(_ rect: CGRect) {
        for beamLine in self.curLayers {
            beamLine.removeFromSuperlayer()
        }

        self.resetBeamedNotes()

        self.curLayers.removeAll()

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

            // for redirecting the cursor after a full measure
            movingStartX = lefRightPadding
            endX = movingStartX + self.distance // initial endX TODO: Remove when implementing adaptive measure
            
            // draw clef before drawing the rest of the staff FOR HORIZONTAL VIEW
            for (index, measure) in measureSplices[0].enumerated() {
                let startPoint = startY + staffSpace * CGFloat(index)
                let _ = drawClefLabel(startX: movingStartX, startY: startPoint, clefType: measure.clef)
            }
            
            for i in 0..<measureSplices.count {
                setupGrandStaff(startX: movingStartX, startY: startY, measures: measureSplices[i])
            }

            // for redirecting the cursor after redrawing the whole composition
            if let recentNotation = GridSystem.instance.recentNotation {

                if let measure = GridSystem.instance.getCurrentMeasure() {

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

                                    measure.updateInvalidNotes(invalidNotes: measure.getInvalidNotes())
                                    
                                    GridSystem.instance.selectedCoord = nextSnapPoint
                                    moveCursorY(location: nextSnapPoint)
                                    moveCursorX(location: CGPoint(x: nextSnapPoint.x, y: sheetCursor.curXCursorLocation.y))

                                }
                                
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
                self.highlightNotation(notation, false)
            }

        }
    }

    //Setup a grand staff
    private func setupGrandStaff(startX:CGFloat, startY:CGFloat, measures:[Measure]) {

        GridSystem.instance.createNewMeasurePointsArray()

        /*let lowerStaffStart = measures.count/2

        var upperStaffMeasures = [Measure]()
        var lowerStaffMeasures = [Measure]()

        for i in 0...lowerStaffStart-1 {
            upperStaffMeasures.append(measures[i])
        }

        for i in lowerStaffStart...measures.count-1 {
            lowerStaffMeasures.append(measures[i])
        }*/

        staffIndex += 1
        let startPoint = startY + staffSpace * staffIndex

        let measureHeight = drawStaff(startX: startX, startY: startY, measures:measures)

        if let height = measureHeight {
            drawStaffConnection(startX: startX, startY: startPoint - height, height: height)
        }
        
        staffIndex = -1
    }

    // Draws a staff
    private func drawStaff(startX:CGFloat, startY:CGFloat, measures:[Measure]) -> CGFloat? {

        let gMeasure = measures[0]
        let fMeasure = measures[1]

        var startYs = [CGFloat]()

        let startPointG = startY + staffSpace * staffIndex
        //let gClefWidth = drawClefLabel(startX: startX, startY: startPointG, clefType: gMeasure.clef)

        staffIndex += 1
        let startPointF = startY + staffSpace * staffIndex
        //let fClefWidth = drawClefLabel(startX: startX, startY: startPointF, clefType: fMeasure.clef)

        startYs.append(startPointG)
        startYs.append(startPointF)

        // Adjust initial space for clef and time signature
        let startMeasure:CGFloat = startX

        // Track distance for each measure to be printed

        // Start drawing the measures
        var modStartX:CGFloat = startMeasure
        var measurePoints = [GridSystem.MeasurePoints]()
        
        var adjustKeyTimeSig: CGFloat = 0

        for i in 0..<measures.count {

            adjustKeyTimeSig = 0

            var keyLabelWidth:CGFloat = 0
            
            if let staffList = composition?.staffList {
                for staff in staffList {
                    if let measureIndex = staff.measures.index(of: measures[i]) {
                        if measureIndex == 0 {
                            adjustKeyTimeSig += clefWidth*1.5
                        } else {
                            adjustKeyTimeSig += 15
                        }
                    }
                }
            }

            // START OF DRAWING KEY SIGNATURE

            if let staffList = composition?.staffList {
                for staff in staffList {
                    if let measureIndex = staff.measures.index(of: measures[i]) {
                        if measureIndex > 0 {
                            if staff.measures[measureIndex - 1].keySignature != staff.measures[measureIndex].keySignature {
                                keyLabelWidth = drawKeySignature(startX: modStartX + adjustKeyTimeSig, startY: startYs[i], keySignature: measures[i].keySignature, clef: measures[i].clef)
                                adjustKeyTimeSig += keyLabelWidth
                            }
                        } else if measureIndex == 0 {
                            keyLabelWidth = drawKeySignature(startX: modStartX + adjustKeyTimeSig, startY: startYs[i], keySignature: measures[i].keySignature, clef: measures[i].clef)
                            adjustKeyTimeSig += keyLabelWidth
                        }
                    }
                }
            }

            // END IF DRAWING KEY SIGNATURE

            var timeLabelWidth:CGFloat?

            if keyLabelWidth > 0 {
                adjustKeyTimeSig += 20
            }

            if let staffList = composition?.staffList {
                for staff in staffList {
                    if let measureIndex = staff.measures.index(of: measures[i]) {
                        if measureIndex > 0 {
                            if staff.measures[measureIndex - 1].timeSignature != staff.measures[measureIndex].timeSignature {

                                timeLabelWidth = drawTimeLabel(startX: modStartX + adjustKeyTimeSig, startY: startYs[i], timeSignature: measures[i].timeSignature)
                            }
                        } else if measureIndex == 0 {
                            timeLabelWidth = drawTimeLabel(startX: modStartX + adjustKeyTimeSig, startY: startYs[i], timeSignature: measures[i].timeSignature)
                        }
                    }
                }
            }
            // END OF DRAWING TIME SIGNATURE

            if let timeLabelWidth = timeLabelWidth {
                modStartX = modStartX + timeLabelWidth
                adjustKeyTimeSig += timeLabelWidth
            }

            modStartX += adjustKeyTimeSig

            // START OF DRAWING OF MEASURE
            //measureLocation = drawMeasure(measure: measures[i], startX: modStartX, endX: modStartX+distance, startY: startY)

            /*if let measureLocation = measureLocation{
                GridSystem.instance.assignMeasureToPoints(measurePoints: measureLocation, measure: measures[i])
                GridSystem.instance.appendMeasurePointToLatestArray(measurePoints: measureLocation)

                modStartX = startMeasure
            }*/

            modStartX = startMeasure
            // END OF DRAWING OF MEASURE
        }
        
        measurePoints = drawParallelMeasures(measures: measures, startX: startX, endX: endX, startYs: startYs,
                                             staffSpace: startPointG - startPointF, leftInnerPadding: adjustKeyTimeSig, rightInnerPadding: 15)
        
        movingStartX = endX
        endX = endX + distance
        
        for measurePoint in measurePoints {
            GridSystem.instance.appendMeasurePointToLatestArray(measurePoints: measurePoint)
        }

        if !measurePoints.isEmpty {
            return measurePoints[0].upperLeftPoint.y - measurePoints[0].lowerRightPoint.y
        } else {
            return nil
        }
    }

    private func drawKeySignature (startX:CGFloat, startY:CGFloat, keySignature:KeySignature, clef: Clef) -> CGFloat {

        if keySignature == .c {
            return 0
        } else {

            var startYForKeySig = startY

            if clef == .G {
                startYForKeySig = startYForKeySig - (lineSpace*5.85)
            } else if clef == .F {
                startYForKeySig = startYForKeySig - (lineSpace*4.75)
            }

            let numberOfAccidentals = abs(keySignature.rawValue)
            let snapPointsForKeySig = GridSystem.instance.createSnapPointsForKeySig(initialX: startX, initialY: startYForKeySig, lineSpace: lineSpace)

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

                    let snapPointSequence = [4, 1, 5, 2, 6, 3, 7]

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
    private func drawClefLabel(startX: CGFloat, startY: CGFloat, clefType: Clef) -> CGFloat {
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

        return 58.2

        // Draws 5 lines
        /*for _ in 0..<5 {
            bezierPath.move(to: CGPoint(x: startX, y: startY - curSpace))
            bezierPath.addLine(to: CGPoint(x: endX, y: startY - curSpace))
            bezierPath.stroke()

            curSpace += lineSpace
        }

        curSpace -= lineSpace // THIS IS NECESSARY FOR ADJUSTING THE LEFT LINE

        // Draws left vertical line
        bezierPath.move(to: CGPoint(x: startX, y: startY - curSpace))
        bezierPath.addLine(to: CGPoint(x: startX, y: startY)) // change if staff space changes
        bezierPath.stroke()*/

        //measureXDivs.insert(startX)

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
        var measureCoord:GridSystem.MeasurePoints =
            GridSystem.MeasurePoints(upperLeftPoint: CGPoint(x: startX, y: startY),
                                     lowerRightPoint: CGPoint(x: endX, y: startY-curSpace),
                                     upperLeftPointWithLedger: CGPoint(x: startX, y: startY+(lineSpace*3.5)),
                                     lowerRightPointWithLedger: CGPoint(x: endX, y: startY-curSpace-(lineSpace*3.5)))

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

        let measureWeights = initMeasureGrid(startX: startX, endX: endX, startY: startY-curSpace)
        GridSystem.instance.assignWeightsToPoints(measurePoints: measureCoord,
                weights: measureWeights)

        let adjustXToCenter = adjustToXCenter * initialNoteSpace

        var lastXCoord:CGFloat?

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

                    //lastXCoord = measureCoord.upperLeftPoint.x + initialNoteSpace + adjustXToCenter

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
                        lastXCoord = prevX

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

                        lastXCoord = prevNoteCoordinates.x + notationSpace + adjustXToCenter

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
                            lastXCoord = prevX

                        }

                    }
                }

                if let noteCoordinates = note.screenCoordinates {

                    drawLedgerLinesIfApplicable(measurePoints: measureCoord, upToLocation: noteCoordinates)

                }
            }

            // beam notes of all measures TODO: change if beaming per group is implemented
            if !measure.groups.isEmpty {

                var x = 0

                if measure.groups.count > 1 {
                    for group in measure.groups {
                        if measure.timeSignature.beats == 4 && measure.timeSignature.beatType == 4 {
                            if x < measure.groups.count {
                                if x + 1 == measure.groups.count {
                                    beamNotes(notations: measure.groups[x])
                                } else {
                                    if isPureEighth(group: measure.groups[x]) && measure.groups[x].count == 2 && isPureEighth(group: measure.groups[x + 1]) && measure.groups[x + 1].count == 2 {
                                        beamNotes(notations: measure.groups[x] + measure.groups[x + 1])
                                        x = x + 1
                                    } else {
                                        beamNotes(notations: measure.groups[x])
                                    }

                                    x = x + 1
                                }
                            }
                        } else {
                            beamNotes(notations: group)
                        }
                    }
                } else {
                    beamNotes(notations: measure.groups[0])
                }
            }

        }

        if let lastCoord = lastXCoord {

            // reassign old snap points to new measure coords
            if let snapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: measureCoord) {

                GridSystem.instance.clearAllSnapPointsFromMeasure(measurePoints: measureCoord)

                if let selectedMeasure = GridSystem.instance.getCurrentMeasure() {

                    if measure == selectedMeasure {

                        measureCoord =
                                GridSystem.MeasurePoints(upperLeftPoint: CGPoint(x: startX, y: startY),
                                        lowerRightPoint: CGPoint(x: lastCoord + 50, y: startY - curSpace),
                                        upperLeftPointWithLedger: CGPoint(x: startX, y: startY + (lineSpace * 3.5)),
                                        lowerRightPointWithLedger: CGPoint(x: lastCoord + 50, y: startY - curSpace - (lineSpace * 3.5)))

                        GridSystem.instance.selectedMeasureCoord = measureCoord

                    } else {

                        measureCoord =
                                GridSystem.MeasurePoints(upperLeftPoint: CGPoint(x: startX, y: startY),
                                        lowerRightPoint: CGPoint(x: lastCoord + 50, y: startY - curSpace),
                                        upperLeftPointWithLedger: CGPoint(x: startX, y: startY + (lineSpace * 3.5)),
                                        lowerRightPointWithLedger: CGPoint(x: lastCoord + 50, y: startY - curSpace - (lineSpace * 3.5)))

                    }

                }

                GridSystem.instance.assignSnapPointsToPoints(measurePoints: measureCoord, snapPoint: snapPoints)

            }

            //draw line after measure
            bezierPath.move(to: CGPoint(x: lastCoord + 50, y: startY - curSpace))
            bezierPath.addLine(to: CGPoint(x: lastCoord + 50, y: startY)) // change if staff space changes
            bezierPath.stroke()

            // for the grand staff connection
            measureXDivs.insert(lastCoord + 50)

        } else {

            //draw line after measure
            bezierPath.move(to: CGPoint(x: endX, y: startY - curSpace))
            bezierPath.addLine(to: CGPoint(x: endX, y: startY)) // change if staff space changes
            bezierPath.stroke()

            // for the grand staff connection
            measureXDivs.insert(endX)

        }

        measureCoords.append(measureCoord)

        return measureCoord
    }

    // ONLY WORKS FOR GRAND STAFF FOR NOW
    private func drawParallelMeasures(measures: [Measure], startX: CGFloat, endX: CGFloat, startYs: [CGFloat], staffSpace: CGFloat,
                                      leftInnerPadding: CGFloat, rightInnerPadding:CGFloat) -> [GridSystem.MeasurePoints] {

        let staffLine = CAShapeLayer()
        staffLine.strokeColor = UIColor.black.cgColor
        staffLine.lineWidth = 2

        let bezierPath = UIBezierPath()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 2

        var curSpace: CGFloat = 0

        measureXDivs.insert(startX)
        measureXDivs.insert(endX)

        for startY in startYs {
            curSpace = 0

            //draw 5 lines
            for _ in 0..<5 {
                bezierPath.move(to: CGPoint(x: startX, y: startY - curSpace))
                bezierPath.addLine(to: CGPoint(x: endX, y: startY - curSpace))
                bezierPath.stroke()

                staffLine.path = bezierPath.cgPath

                self.layer.addSublayer(staffLine)
                self.curLayers.append(staffLine)

                curSpace += lineSpace
            }

            curSpace -= lineSpace

            bezierPath.move(to: CGPoint(x: startX, y: startY - curSpace))
            bezierPath.addLine(to: CGPoint(x: startX, y: startY)) // change if staff space changes
            bezierPath.stroke()

            staffLine.path = bezierPath.cgPath

            self.layer.addSublayer(staffLine)
            self.curLayers.append(staffLine)

            bezierPath.move(to: CGPoint(x: endX, y: startY - curSpace))
            bezierPath.addLine(to: CGPoint(x: endX, y: startY)) // change if staff space changes
            bezierPath.stroke()

            staffLine.path = bezierPath.cgPath

            self.layer.addSublayer(staffLine)
            self.curLayers.append(staffLine)
        }

        var grandStaffMeasurePoints = [GridSystem.MeasurePoints]()

        for (index, measure) in measures.enumerated() {

            let measureCoord:GridSystem.MeasurePoints =
                    GridSystem.MeasurePoints(upperLeftPoint: CGPoint(x: startX, y: startYs[index]),
                            lowerRightPoint: CGPoint(x: endX, y: startYs[index]-curSpace),
                            upperLeftPointWithLedger: CGPoint(x: startX, y: startYs[index]+(lineSpace*3.5)),
                            lowerRightPointWithLedger: CGPoint(x: endX, y: startYs[index]-curSpace-(lineSpace*3.5)))
            GridSystem.instance.assignMeasureToPoints(measurePoints: measureCoord, measure: measure)

            grandStaffMeasurePoints.append(measureCoord)

            let snapPoints = GridSystem.instance.createSnapPoints(initialX: startX + initialNoteSpace + leftInnerPadding,
                    initialY: startYs[index] - curSpace - (lineSpace * 3.5), clef: measure.clef, lineSpace: lineSpace)
            GridSystem.instance.assignSnapPointsToPoints(measurePoints: measureCoord, snapPoint: snapPoints)

            if measure.clef == .G {
                gMeasurePoints.append(measureCoord)
            } else {
                fMeasurePoints.append(measureCoord)
            }
            measureCoords.append(measureCoord)
            
            if GridSystem.instance.selectedMeasureCoord == nil {
                GridSystem.instance.selectedMeasureCoord = measureCoord
                
                // the middle snap point
                GridSystem.instance.selectedCoord = snapPoints[11]
                
                moveCursorX(location: CGPoint(x: snapPoints[0].x, y: measureCoord.lowerRightPoint.y + cursorXOffsetY))
                moveCursorY(location: snapPoints[11])
            }

        }

        // start of notes parallel
        var gTally: Float = 0
        var fTally: Float = 0

        let gNotations = measures[0].notationObjects
        let fNotations = measures[1].notationObjects

        var gIndex = 0
        var fIndex = 0
        
        var gReachedEnd = false
        var fReachedEnd = false
        
        var gAlreadyAdded = false
        var fAlreadyAdded = false

        var grpdNotesToBePrinted = [[MusicNotation]]()

        while !(gReachedEnd && fReachedEnd) {
            gAlreadyAdded = false
            fAlreadyAdded = false
            var notesToBePrinted = [MusicNotation]()
            
            if gIndex == gNotations.count {
                gReachedEnd = true
            }
            
            if fIndex == fNotations.count {
                fReachedEnd = true
            }

            if gTally == fTally {
                if gIndex < gNotations.count {
                    gTally += gNotations[gIndex].type.getBeatValue()
                    notesToBePrinted.append(gNotations[gIndex])

                    gIndex += 1
                    
                    gAlreadyAdded = true
                }
                if fIndex < fNotations.count {
                    fTally += fNotations[fIndex].type.getBeatValue()
                    notesToBePrinted.append(fNotations[fIndex])

                    fIndex += 1
                    
                    fAlreadyAdded = true
                }
            } else if gTally < fTally {
                if gIndex < gNotations.count {
                    gTally += gNotations[gIndex].type.getBeatValue()
                    notesToBePrinted.append(gNotations[gIndex])

                    gIndex += 1
                    
                    gAlreadyAdded = true
                }
            } else if fTally < gTally {
                if fIndex < fNotations.count {
                    fTally += fNotations[fIndex].type.getBeatValue()
                    notesToBePrinted.append(fNotations[fIndex])

                    fIndex += 1
                    
                    fAlreadyAdded = true
                }
            }
            
            if gReachedEnd && !fReachedEnd && !fAlreadyAdded {
                if fIndex < fNotations.count {
                    fTally += fNotations[fIndex].type.getBeatValue()
                    notesToBePrinted.append(fNotations[fIndex])
                    
                    fIndex += 1
                }
            } else if fReachedEnd && !gReachedEnd && !gAlreadyAdded {
                if gIndex < gNotations.count {
                    gTally += gNotations[gIndex].type.getBeatValue()
                    notesToBePrinted.append(gNotations[gIndex])
                    
                    gIndex += 1
                }
            }

            grpdNotesToBePrinted.append(notesToBePrinted)

        }

        var noteSpace: CGFloat = 0

        if !measures[0].isFull || !measures[1].isFull {
            noteSpace = (grandStaffMeasurePoints[0].width - initialNoteSpace - leftInnerPadding - CGFloat(grpdNotesToBePrinted.count)) /
                    CGFloat(grpdNotesToBePrinted.count) // not still sure about this
        } else {
            noteSpace = (grandStaffMeasurePoints[0].width - initialNoteSpace - leftInnerPadding - CGFloat(grpdNotesToBePrinted.count)) /
                    CGFloat(grpdNotesToBePrinted.count - 1)
        }

        var currentStartX: CGFloat = startX + initialNoteSpace + leftInnerPadding

        for notesToBePrinted in grpdNotesToBePrinted {
            for note in notesToBePrinted {
                if let measure = note.measure {
                    if let measurePoints = GridSystem.instance.getPointsFromMeasure(measure: measure) {
                        if let snapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: measurePoints) {
                            
                            if let chord = note as? Chord {
                                for note in chord.notes {
                                    note.screenCoordinates =
                                        CGPoint(x: currentStartX,
                                                y: GridSystem.instance.getYFromPitch(notation: note, clef: measure.clef, snapPoints: snapPoints))
                                }
                            } else if note is Note {
                                note.screenCoordinates =
                                        CGPoint(x: currentStartX,
                                                y: GridSystem.instance.getYFromPitch(notation: note, clef: measure.clef, snapPoints: snapPoints))
                            } else if note is Rest {

                                if let height = note.image?.size.height {

                                    note.screenCoordinates =
                                            CGPoint(x: currentStartX,
                                                    y: (measurePoints.upperLeftPoint.y + measurePoints.lowerRightPoint.y) / 2 - (height / restHeightAlter / 2))

                                }
                            }

                            //lastXCoord = measureCoord.upperLeftPoint.x + initialNoteSpace + adjustXToCenter

                            let snapPointsRelativeToNotation = GridSystem.instance.createSnapPoints(
                                    initialX: currentStartX + adjustToXCenter * initialNoteSpace,
                                    initialY: measurePoints.lowerRightPoint.y - (lineSpace * 3.5), clef: measure.clef, lineSpace: lineSpace)

                            // snap points for added note
                            GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measurePoints,
                                    snapPoints: snapPointsRelativeToNotation)

                            GridSystem.instance.removeRelativeXSnapPoints(measurePoints: measurePoints,
                                    relativeX: startX + initialNoteSpace + leftInnerPadding)
                            GridSystem.instance.removeRelativeXSnapPoints(measurePoints: measurePoints,
                                    relativeX: currentStartX - noteSpace + adjustToXCenter * initialNoteSpace + 35)

                            // assign snap point to added note or rest
                            if let chord = note as? Chord {
                                for note in chord.notes {
                                    GridSystem.instance.assignSnapPointToNotation(
                                        snapPoint: CGPoint(x: currentStartX + adjustToXCenter * initialNoteSpace,
                                                           y: GridSystem.instance.getYFromPitch(notation: note, clef: measure.clef, snapPoints: snapPoints)),
                                        notation: note)
                                }
                            } else if note is Note {
                                GridSystem.instance.assignSnapPointToNotation(
                                        snapPoint: CGPoint(x: currentStartX + adjustToXCenter * initialNoteSpace,
                                                y: GridSystem.instance.getYFromPitch(notation: note, clef: measure.clef, snapPoints: snapPoints)),
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
                                        initialX: currentStartX + adjustToXCenter * initialNoteSpace + 35,
                                        initialY: measurePoints.lowerRightPoint.y - (lineSpace * 3.5), clef: measure.clef, lineSpace: lineSpace)

                                GridSystem.instance.addMoreSnapPointsToPoints(measurePoints: measurePoints,
                                        snapPoints: additionalSnapPoints)

                            }
                        }
                    }

                }

            }

            currentStartX += noteSpace
        }

        for measure in measures {
            if !measure.groups.isEmpty {

                var x = 0

                if measure.groups.count > 1 {
                    for group in measure.groups {
                        if measure.timeSignature.beats == 4 && measure.timeSignature.beatType == 4 {
                            if x < measure.groups.count {
                                if x + 1 == measure.groups.count {
                                    beamNotes(notations: measure.groups[x])
                                } else {
                                    if isPureEighth(group: measure.groups[x]) && measure.groups[x].count ==
                                            2 && isPureEighth(group: measure.groups[x + 1]) && measure.groups[x + 1].count == 2 {
                                        beamNotes(notations: measure.groups[x] + measure.groups[x + 1])
                                        x = x + 1
                                    } else {
                                        beamNotes(notations: measure.groups[x])
                                    }

                                    x = x + 1
                                }
                            }
                        } else {
                            beamNotes(notations: group)
                        }
                    }
                } else {
                    beamNotes(notations: measure.groups[0])
                }
            }
        }

        return grandStaffMeasurePoints
    }

    private func getMeasureWidth(measure: Measure, withClef: Bool? = true, withKeySig: Bool? = true, withTimeSig: Bool? = true) -> CGFloat {
        // TODO: Modify this if accidentals are implemented
        var width:CGFloat = 0

        for notation in measure.notationObjects {
            if let notationImage = notation.image {
                width += notationImage.size.width + noteWidthAlter + notation.getBaseNotationSpace()
            }
        }

        if withClef! {
            width += 58.2 // width of clef
        }

        if withKeySig! {
            width += getKeySignatureWidth(keySignature: measure.keySignature)
        }

        if withTimeSig! {
            width += getTimeSignatureWidth(timeSignature: measure.timeSignature)
        }

        return width
    }

    private func getKeySignatureWidth(keySignature: KeySignature) -> CGFloat {
        if keySignature == .c {
            return 0.0
        } else {
            let numberOfAccidentals = abs(keySignature.rawValue)

            return CGFloat( numberOfAccidentals * ((56/3) + 15) ) // width of key signature + spacing for each accidental
        }
    }

    private func getTimeSignatureWidth(timeSignature: TimeSignature) -> CGFloat {
        // default width for 1 digit time signature
        var maxWidth:CGFloat = 32

        let upperText = String(timeSignature.beats)
        let lowerText = String(timeSignature.beatType)

        // adjust width for time signature based on number of digits
        if maxWidth * CGFloat(upperText.count) >= maxWidth * CGFloat(lowerText.count) {
            maxWidth = maxWidth * CGFloat(upperText.count)
        } else if maxWidth * CGFloat(lowerText.count) >= maxWidth * CGFloat(upperText.count) {
            maxWidth = maxWidth * CGFloat(lowerText.count)
        }

        return maxWidth
    }

    func isPureEighth(group: [MusicNotation]) -> Bool {
        for note in group {
            if note.type != .eighth {
                return false
            }
        }

        return true
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

        self.layer.addSublayer(staffConnection)
        self.curLayers.append(staffConnection)

        let brace = UIImage(named:"brace-185")
        let braceView = UIImageView(frame: CGRect(x: lefRightPadding - 25, y: startY, width: 22.4, height: staffSpace + height))

        measureXDivs.removeAll()

        braceView.image = brace
        self.addSubview(braceView)
    }

    public func addMusicNotation(notation: MusicNotation) {

        var notationImageViews = [UIImageView]()

        if let chord = notation as? Chord {
            
            for note in chord.notes {
                
                if let screenCoordinates = note.screenCoordinates, let image = note.image {
                    notationImageViews.append(
                        UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter)))
                    
                    drawAccidentalByNote(note: note)
                    
                    if let measure = chord.measure {
                        if let measurePoints = GridSystem.instance.getPointsFromMeasure(measure: measure) {
                            drawLedgerLinesIfApplicable(measurePoints: measurePoints, upToLocation: screenCoordinates)
                        }
                    }
                }
                
            }
            
        } else if let note = notation as? Note {
            
            if let screenCoordinates = note.screenCoordinates, let image = note.image {
                
                notationImageViews.append(
                    UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter)))
                
                drawAccidentalByNote(note: note)
                
                if let measure = note.measure {
                    if let measurePoints = GridSystem.instance.getPointsFromMeasure(measure: measure) {
                        drawLedgerLinesIfApplicable(measurePoints: measurePoints, upToLocation: screenCoordinates)
                    }
                }
                
            }
            
        } else if let rest = notation as? Rest {
            
            if let screenCoordinates = rest.screenCoordinates, let image = rest.image {
            
                if rest.type == .whole {
                    notationImageViews.append(
                        UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + restYOffset + wholeRestYOffset, width: image.size.width / restWidthAlter, height: image.size.height / restHeightAlter)))
                } else if rest.type == .half {
                    notationImageViews.append(
                        UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + restYOffset + halfRestYOffset, width: image.size.width / restWidthAlter, height: image.size.height / restHeightAlter)))
                } else {
                    notationImageViews.append(
                        UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + restYOffset, width: image.size.width / restWidthAlter, height: image.size.height / restHeightAlter)))
                }
                
            }
        }

        for notationImageView in notationImageViews {
            notationImageView.image = notation.image
            
            self.addSubview(notationImageView)
        }
        
    }

    private func drawAccidentalByNote (note: Note, highlighted: Bool = false) {
        if let screenCoordinates = note.screenCoordinates {
            if let accidental = note.accidental {

                var printAccidental = true

                if let measure = note.measure {
                    if let noteIndex = measure.notationObjects.index(of: note) {
                        if noteIndex != 0 {
                            var currIndex = noteIndex - 1

                            while currIndex > -1 {

                                if let prevNote = measure.notationObjects[currIndex] as? Note {

                                    if prevNote.pitch == note.pitch {
                                        if let prevAccidental = prevNote.accidental {

                                            if prevAccidental == accidental {
                                                printAccidental = false
                                            }

                                            break

                                        } else {

                                            if accidental == .natural {
                                                printAccidental = false
                                            } else {
                                                printAccidental = true
                                            }
                                            break
                                        }
                                    }

                                }

                                currIndex -= 1
                            }
                        } else {
                            if accidental == .natural {
                                printAccidental = false
                            }
                        }
                    }
                }

                if printAccidental {
                    var accidentalImageView:UIImageView?

                    if accidental == .sharp, let image = UIImage(named: "sharp") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset, y: screenCoordinates.y + sharpAccidentalYOffset, width: 56/3, height: 150/3))

                        accidentalImageView!.image = image
                    } else if accidental == .flat, let image = UIImage(named: "flat") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset, y: screenCoordinates.y + flatAccidentalYOffset, width: 56/3, height: 150/3))

                        accidentalImageView!.image = image
                    } else if accidental == .natural, let image = UIImage(named: "natural") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset, y: screenCoordinates.y + naturalAccidentalYOffset, width: 56/4, height: 150/3))

                        accidentalImageView!.image = image
                    } else if accidental == .doubleSharp, let accImage = UIImage(named: "double-sharp"), let noteHead = UIImage(named: "quarter-head") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset - 8, y: screenCoordinates.y + doubleSharpAccidentalYOffset, width: noteHead.size.height/9.5, height: noteHead.size.height/9.5))

                        accidentalImageView!.image = accImage
                    }

                    if let accidentalImageView = accidentalImageView {
                        if highlighted {
                            accidentalImageView.image = accidentalImageView.image!.withRenderingMode(.alwaysTemplate)
                            accidentalImageView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                            accidentalImageView.tag = HIGHLIGHTED_NOTES_TAG
                        }

                        self.addSubview(accidentalImageView)
                    }
                }
            } else {

                var printNatural = false

                if let measure = note.measure {
                    if let noteIndex = measure.notationObjects.index(of: note) {
                        if noteIndex != 0 {
                            var currIndex = noteIndex - 1

                            while currIndex > -1 {

                                if let prevNote = measure.notationObjects[currIndex] as? Note {

                                    if prevNote.pitch == note.pitch {
                                        if let prevAccidental = prevNote.accidental {

                                            if prevAccidental != .natural {
                                                printNatural = true
                                            }

                                            break
                                        } else {
                                            break
                                        }
                                    }

                                }

                                currIndex -= 1
                            }
                        }
                    }
                }

                var accidentalImageView:UIImageView?

                if printNatural {
                    if let image = UIImage(named: "natural") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset, y: screenCoordinates.y + naturalAccidentalYOffset, width: 56/4, height: 150/3))

                        accidentalImageView!.image = image
                    }

                    if let accidentalImageView = accidentalImageView {
                        if highlighted {
                            accidentalImageView.image = accidentalImageView.image!.withRenderingMode(.alwaysTemplate)
                            accidentalImageView.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                            accidentalImageView.tag = HIGHLIGHTED_NOTES_TAG
                        }

                        self.addSubview(accidentalImageView)
                    }
                }

            }
        }
    }

    func transposeUp() {
        if !self.selectedNotations.isEmpty {
            self.transpose(direction: .up)

            /*let params = Parameters()

            if let coord = selectedNotations.last?.screenCoordinates {
                //print("NANI2")
                params.put(key: KeyNames.TRANSPOSE_KEYS_COORD, value: coord)
                EventBroadcaster.instance.postEvent(event: EventNames.SHOW_TRANSPOSE_KEYS, params: params)
            }*/
            //return;
        }
    }

    func transposeDown() {
        if !self.selectedNotations.isEmpty {
            self.transpose(direction: .down)

            /*let params = Parameters()

            if let coord = selectedNotations.last?.screenCoordinates {
                //print("NANI2")
                params.put(key: KeyNames.TRANSPOSE_KEYS_COORD, value: coord)
                EventBroadcaster.instance.postEvent(event: EventNames.SHOW_TRANSPOSE_KEYS, params: params)
            }*/
            //return;
        }
    }

    func onArrowKeyPressed(params: Parameters) {
        let direction:ArrowKey = params.get(key: KeyNames.ARROW_KEY_DIRECTION) as! ArrowKey
        var nextPoint:CGPoint = sheetCursor.curYCursorLocation

        if direction == ArrowKey.up {

            if let point = GridSystem.instance.getUpYSnapPoint(currentPoint: sheetCursor.curYCursorLocation) {
                nextPoint = point
            } else {
                return
            }

        } else if direction == ArrowKey.down {

            /*if !self.selectedNotations.isEmpty {
                self.transpose(direction: .down)
                return;
            }*/

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
    
    private func transpose(direction: TranspositionDirection) {
        for notation in self.selectedNotations {
            if let note = notation as? Note {
                if self.transpositions == 0 {
                    self.initialPitches.append(note.pitch)
                }
                
                if direction == .up {
                    note.transposeUp()
                } else {
                    note.transposeDown()
                }
                
            }
        }
        self.transpositions += 1
        self.updateMeasureDraw()
    }
    
    public func moveCursorY(location: CGPoint) {
        sheetCursor.moveCursorY(location: location)

        print(location)

        if let measurePoints = GridSystem.instance.selectedMeasureCoord {
            sheetCursor.showLedgerLinesGuide(measurePoints: measurePoints, upToLocation: location, lineSpace: lineSpace)
        }

        if let notation = GridSystem.instance.getNotationFromSnapPoint(snapPoint: location) {
            hoveredNotation = notation
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        EventBroadcaster.instance.postEvent(event: EventNames.HIDE_TEMPO_MENU)
        
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        EventBroadcaster.instance.postEvent(event: EventNames.HIDE_TEMPO_MENU)
        
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)

        if self.selectedNotations.count > 0 {
            // Remove highlight
            while let highlightView = self.viewWithTag(HIGHLIGHTED_NOTES_TAG) {
                highlightView.removeFromSuperview()
            }
            
            self.processTranspositions()

            // Remove selected notes
            for note in self.selectedNotations {
                note.isSelected = false
            }
            self.selectedNotations.removeAll()

            return
        }

        remapCurrentMeasure(location: location)
        moveCursorsToNearestSnapPoint(location: location)
    }
    
    private func processTranspositions() {
        // Process transpositions
        if self.transpositions != 0 {
            var newNotations = [MusicNotation]()
            for notation in self.selectedNotations {
                newNotations.append(notation.duplicate())
                
                if let note = notation as? Note {
                    note.pitch = self.initialPitches.removeFirst()
                }
            }
            
            /*if self.transpositions > 0 {
                for _ in 0..<self.transpositions {
                    for notation in self.selectedNotations {
                        if let note = notation as? Note {
                            note.transposeDown()
                        }
                    }
                }
            } else if self.transpositions < 0 {
                for _ in 0..<abs(self.transpositions) {
                    for notation in self.selectedNotations {
                        if let note = notation as? Note {
                            note.transposeUp()
                        }
                    }
                }
            }*/
            
            let editAction = EditAction(old: self.selectedNotations, new: newNotations)
            editAction.execute()
            self.updateMeasureDraw()
            
            self.transpositions = 0
            self.initialPitches.removeAll()
        }
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
        gMeasurePoints.removeAll()
        fMeasurePoints.removeAll()
        GridSystem.instance.clearNotationSnapPointMap()

        self.setNeedsDisplay()

        print("finished updating the view")
    }

    @objc func draggedView(_ sender:UIPanGestureRecognizer) {
        
        EventBroadcaster.instance.postEvent(event: EventNames.HIDE_TEMPO_MENU)
        
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
                if let chord = notation as? Chord {
                    for note in chord.notes {
                        if let coor = note.screenCoordinates {
                            let rect = self.highlightRect.rect
                            if rect.contains(coor) {
                                notation.isSelected = true
                                self.selectedNotations.append(note)
                                self.highlightNotation(note, false)
                            }
                        }
                    }
                } else if let coor = notation.screenCoordinates {
                    let rect = self.highlightRect.rect
                    if rect.contains(coor) {
                        notation.isSelected = true
                        self.selectedNotations.append(notation)
                        self.highlightNotation(notation, false)
                    }
                }
            }
        }
    }

    func highlightNotation(_ notation: MusicNotation, _ hovered: Bool) {
        var notationImageView: UIImageView?

        var image: UIImage? = nil
        
        if let note = notation as? Note {
            
            if let screenCoordinates = note.screenCoordinates {

                image = note.image

                if note.type.getBeatValue() <= RestNoteType.eighth.getBeatValue() && note.beamed {
                    image = UIImage(named: "quarter-head")
                }

                if let image = image {
                    notationImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter))
                    drawAccidentalByNote(note: note, highlighted: true)
                }
                
            }
            
        } else if let rest = notation as? Rest {
            
            if let screenCoordinates = rest.screenCoordinates {

                image = rest.image

                if let image = image {
                    if rest.type == .whole {
                        notationImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + restYOffset + wholeRestYOffset, width: image.size.width / restWidthAlter, height: image.size.height / restHeightAlter))
                    } else if rest.type == .half {
                        notationImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + restYOffset + halfRestYOffset, width: image.size.width / restWidthAlter, height: image.size.height / restHeightAlter))
                    } else {
                        notationImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + restYOffset, width: image.size.width / restWidthAlter, height: image.size.height / restHeightAlter))
                    }
                }
                
            }
        }
        
        if let notationImageView = notationImageView {
            if let image = image {

                var color =  UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)

                if hovered {
                    color = UIColor(red: 0.0, green: 175.0 / 255.0, blue: 1.0, alpha: 1.0)
                }

                notationImageView.image = image
                notationImageView.image = notationImageView.image!.withRenderingMode(.alwaysTemplate)
                notationImageView.tintColor = color
                notationImageView.tag = HIGHLIGHTED_NOTES_TAG

                self.addSubview(notationImageView)
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
        
        if let currentMeasurePoints = GridSystem.instance.selectedMeasureCoord,
           let measure = GridSystem.instance.getCurrentMeasure() {

            var clefMeasurePoints: [GridSystem.MeasurePoints]?

            if measure.clef == .G {
                clefMeasurePoints = gMeasurePoints
            } else if measure.clef == .F {
                clefMeasurePoints = fMeasurePoints
            }

            if let clefMeasurePoints = clefMeasurePoints {
                if let index = clefMeasurePoints.index(of: currentMeasurePoints) {

                    if (index + 1) < clefMeasurePoints.count {

                        if let currentSnapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: currentMeasurePoints) {

                            let newMeasurePoints = clefMeasurePoints[index + 1]

                            // getting the first row of snap points that are equal to the current y
                            if let prevSnapIndex = currentSnapPoints.index(where: {$0.y == sheetCursor.curYCursorLocation.y}) {

                                if let newSnapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: newMeasurePoints) {

                                    GridSystem.instance.selectedMeasureCoord = newMeasurePoints
                                    GridSystem.instance.selectedCoord = newSnapPoints[prevSnapIndex]

                                    GridSystem.instance.currentStaffIndex =
                                            GridSystem.instance.getStaffIndexFromMeasurePoint(measurePoints: newMeasurePoints)

                                    if let firstMeasurePoints = GridSystem.instance.getFirstMeasurePointFromStaff(measurePoints: newMeasurePoints) {

                                        moveCursorX(location: CGPoint(x: newSnapPoints[prevSnapIndex].x,
                                                y: firstMeasurePoints.lowerRightPoint.y + cursorXOffsetY))
                                        moveCursorY(location: newSnapPoints[prevSnapIndex])

                                        //scrollMusicSheetToY(y: newMeasurePoints.lowerRightPoint.y - 140)
                                        //scrollMusicSheetToX(x: newMeasurePoints.upperLeftPoint.x - 140)
                                        
                                        scrollMusicSheetToYIfPointNotVisible(y: newMeasurePoints.lowerRightPoint.y - 140, targetPoint: newMeasurePoints.lowerRightPoint)
                                        scrollMusicSheetToXIfPointNotVisible(x: newMeasurePoints.upperLeftPoint.x - 140, targetPoint: newMeasurePoints.lowerRightPoint)

                                    }

                                }

                            }
                        }

                    }

                }
            }
            
        }
    }

    // ONLY USE THIS IF YOU ARE SELECTING SNAP POINTS IN THE FIRST COLUMN
    private func moveCursorsToPreviousMeasure(measurePoints: GridSystem.MeasurePoints) { // relative to clef

        if let currentMeasurePoints = GridSystem.instance.selectedMeasureCoord,
           let measure = GridSystem.instance.getCurrentMeasure() {

            var clefMeasurePoints: [GridSystem.MeasurePoints]?

            if measure.clef == .G {
                clefMeasurePoints = gMeasurePoints
            } else if measure.clef == .F {
                clefMeasurePoints = fMeasurePoints
            }

            if let clefMeasurePoints = clefMeasurePoints {
                if let index = clefMeasurePoints.index(of: currentMeasurePoints) {

                    if index - 1 > -1 {

                        if let currentSnapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: currentMeasurePoints) {

                            let newMeasurePoints = clefMeasurePoints[index - 1]

                            // getting the first row of snap points that are equal to the current y
                            if let prevSnapIndex = currentSnapPoints.index(where: {$0.y == sheetCursor.curYCursorLocation.y}) {

                                if let newSnapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: newMeasurePoints) {

                                    let newPoint = newSnapPoints[(newSnapPoints.count-1) - prevSnapIndex]

                                    GridSystem.instance.selectedMeasureCoord = newMeasurePoints
                                    GridSystem.instance.selectedCoord = newPoint

                                    GridSystem.instance.currentStaffIndex =
                                            GridSystem.instance.getStaffIndexFromMeasurePoint(measurePoints: newMeasurePoints)

                                    if let firstMeasurePoints = GridSystem.instance.getFirstMeasurePointFromStaff(measurePoints: newMeasurePoints) {

                                        moveCursorX(location: CGPoint(x: newPoint.x,
                                                y: firstMeasurePoints.lowerRightPoint.y + cursorXOffsetY))
                                        moveCursorY(location: newPoint)

                                        //scrollMusicSheetToY(y: newMeasurePoints.lowerRightPoint.y - 140)
                                        //scrollMusicSheetToX(x: newMeasurePoints.upperLeftPoint.x - 140)
                                        
                                        scrollMusicSheetToYIfPointNotVisible(y: newMeasurePoints.lowerRightPoint.y - 140, targetPoint: sheetCursor.curYCursorLocation)
                                        scrollMusicSheetToXIfPointNotVisible(x: newMeasurePoints.upperLeftPoint.x - 140, targetPoint: sheetCursor.curYCursorLocation)

                                    }

                                }

                            }
                        }

                    }

                }
            }

        }
        
    }

    private func scrollMusicSheetToY (y: CGFloat, animated: Bool = true) {
        if let outerScrollView = self.superview as? UIScrollView {
            outerScrollView.setContentOffset(
                CGPoint(x: outerScrollView.contentOffset.x, y: y), animated: animated)
        }
    }
    
    private func scrollMusicSheetToX (x: CGFloat, animated: Bool = true) {
        if let outerScrollView = self.superview as? UIScrollView {
            outerScrollView.setContentOffset(
                CGPoint(x: x, y: outerScrollView.contentOffset.y), animated: animated)
        }
    }
    
    private func scrollMusicSheetToYIfPointNotVisible (y: CGFloat, targetPoint: CGPoint, animated: Bool = true) {
        if let outerScrollView = self.superview as? UIScrollView {
            
            let r:CGRect = CGRect(x: outerScrollView.contentOffset.x, y: outerScrollView.contentOffset.y,
                                  width: outerScrollView.frame.width,
                                  height: outerScrollView.frame.height)
            
            if !r.contains(targetPoint) {
                outerScrollView.setContentOffset(
                    CGPoint(x: outerScrollView.contentOffset.x, y: y), animated: animated)
            }
        }
    }
    
    private func scrollMusicSheetToXIfPointNotVisible (x: CGFloat, targetPoint: CGPoint, animated: Bool = true) {
        if let outerScrollView = self.superview as? UIScrollView {
            
            let r:CGRect = CGRect(x: outerScrollView.contentOffset.x, y: outerScrollView.contentOffset.y,
                                  width: outerScrollView.frame.width,
                                  height: outerScrollView.frame.height)
            
            if !r.contains(targetPoint) {
                outerScrollView.setContentOffset(
                    CGPoint(x: x, y: outerScrollView.contentOffset.y), animated: animated)
            }
        }
    }
    
    private func scrollViewYIsEqualToY(y: CGFloat) -> Bool {
        if let outerScrollView = self.superview as? UIScrollView {
            return outerScrollView.contentOffset.y == y
        }
        
        return false
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
        let line = CAShapeLayer()

        line.strokeColor = UIColor.black.cgColor
        line.lineWidth = thickness

        path.lineWidth = thickness
        path.move(to: start)
        path.addLine(to: end)
        path.stroke()

        line.path = path.cgPath

        self.layer.addSublayer(line)
        self.curLayers.append(line)

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

    func resetBeamedNotes() {
        if let comp = self.composition {
            for staff in comp.staffList {
                for measure in staff.measures {
                    for notation in measure.notationObjects {
                        if let note = notation as? Note {
                            note.beamed = false
                        }
                    }
                }
            }
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

                note.beamed = true
            }

            if notation.type == RestNoteType.sixtyFourth {
                stemHeight = 80
            }
        }

        // check whether there are more upward notes and vice versa
        if upCount > downCount {
            let highestNote = getLowestOrHighestNote(highest: true, notations: notations)
            let highestY: CGFloat = highestNote.screenCoordinates!.y - stemHeight - 4
            //let startX: CGFloat = notations[0].screenCoordinates!.x + noteXOffset + 23.9

            var startX: CGFloat = 0.0

            if let notation = notations[0] as? Chord {
                startX = notation.notes[0].screenCoordinates!.x + noteXOffset + 23.9
            } else {
                startX = notations[0].screenCoordinates!.x + noteXOffset + 23.9
            }

            var endX: CGFloat = 0.0

            if let notation = notations[notations.count - 1] as? Chord {
                endX = notation.notes[0].screenCoordinates!.x + noteXOffset + 23.9 + 2
            } else {
                endX = notations[notations.count - 1].screenCoordinates!.x + noteXOffset + 23.9 + 2
            }

            //let endX: CGFloat = notations[notations.count - 1].screenCoordinates!.x + noteXOffset + 23.9 + 2

            var curSameNotes = [MusicNotation]()

            for notation in notations {
                var notation = notation

                if let chord = notation as? Chord {
                    notation = getLowestOrHighestNoteChord(highest: true, notations: chord.notes)

                    for note in chord.notes {
                        let curHeight = note.screenCoordinates!.y - highestY

                        assembleNoteForBeaming(notation: note, stemHeight: curHeight, isUpwards: true)
                    }
                } else {
                    let curHeight = notation.screenCoordinates!.y - highestY

                    assembleNoteForBeaming(notation: notation, stemHeight: curHeight, isUpwards: true)
                }


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
            var startX: CGFloat = 0.0

            if let notation = notations[0] as? Chord {
                startX = notation.notes[0].screenCoordinates!.x + noteXOffset + 0.5
            } else {
                startX = notations[0].screenCoordinates!.x + noteXOffset + 0.5
            }

            var endX: CGFloat = 0.0

            if let notation = notations[notations.count - 1] as? Chord {
                endX = notation.notes[0].screenCoordinates!.x + noteXOffset + 0.5 + 2
            } else {
                endX = notations[notations.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2
            }

            //let endX: CGFloat = notations[notations.count - 1].screenCoordinates!.x + noteXOffset + 0.5 + 2

            var curSameNotes = [MusicNotation]()

            for notation in notations {
                var notation = notation
                
                if notation is Chord {
                    if let chord = notation as? Chord {
                        notation = getLowestOrHighestNoteChord(highest: false, notations: chord.notes)

                        for note in chord.notes {
                            let curHeight = lowestY - note.screenCoordinates!.y

                            assembleNoteForBeaming(notation: note, stemHeight: curHeight, isUpwards: false)
                        }
                    }
                } else {
                    let curHeight = lowestY - notation.screenCoordinates!.y

                    assembleNoteForBeaming(notation: notation, stemHeight: curHeight, isUpwards: false)
                }
    
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
        if let note = notation as? Note {
            drawAccidentalByNote(note: note)
        }

        if isUpwards {
            let _ = self.drawLine(start: CGPoint(x: noteX + 24.9, y: noteY - noteYOffset - 4), end: CGPoint(x: noteX + 24.9, y: noteY - noteYOffset - stemHeight - 4), thickness: 2.3)
            //drawLine(start: CGPoint(x: noteX + 23.9, y: noteY - noteYOffset - stemHeight + lineSpace / 2 + lineSpace / 4), end: CGPoint(x: noteX + 23.9 + 22, y: noteY - noteYOffset - stemHeight + lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
        } else {
            let _ = self.drawLine(start: CGPoint(x: noteX + 1.5, y: noteY - noteYOffset + 3), end: CGPoint(x: noteX + 1.5, y: noteY - noteYOffset + stemHeight + 3), thickness: 2.3)
            //drawLine(start: CGPoint(x: noteX + 0.5, y: noteY - noteYOffset + stemHeight - lineSpace / 2 + lineSpace / 4), end: CGPoint(x: noteX + 0.5 + 22, y: noteY - noteYOffset + stemHeight - lineSpace / 2 + lineSpace / 4), thickness: lineSpace / 2)
        }
    }

    public func getLowestOrHighestNote(highest: Bool, notations: [MusicNotation]) -> MusicNotation {
        var note: MusicNotation

        if let notation = notations[0] as? Chord {
            note = getLowestOrHighestNoteChord(highest: highest, notations: notation.notes)
        } else {
            note = notations[0]
        }

        for notation in notations {
            if !highest {

                if let notation = notation as? Chord {
                    var lowestNotation = getLowestOrHighestNoteChord(highest: highest, notations: notation.notes)

                    if lowestNotation.screenCoordinates!.y > note.screenCoordinates!.y {
                        note = lowestNotation
                    }
                } else {
                    if notation.screenCoordinates!.y > note.screenCoordinates!.y {
                        note = notation
                    }
                }
            } else {
                if let notation = notation as? Chord {
                    var highestNotation = getLowestOrHighestNoteChord(highest: highest, notations: notation.notes)

                    if highestNotation.screenCoordinates!.y < note.screenCoordinates!.y {
                        note = highestNotation
                    }
                } else {
                    if notation.screenCoordinates!.y < note.screenCoordinates!.y {
                        note = notation
                    }
                }
            }
        }

        return note
    }

    public func getLowestOrHighestNoteChord(highest: Bool, notations: [MusicNotation]) -> MusicNotation {
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
        self.superview!.hideAllToasts()
        print("Copy")
        if !self.selectedNotations.isEmpty {
            Clipboard.instance.copy(self.selectedNotations)
            self.superview!.makeToast("Copied notations", duration: 1.5, position: .bottom, image: UIImage(named: "copy-icon-white"))
        } else if let hovered = self.hoveredNotation {
            Clipboard.instance.copy([hovered])
            self.superview!.makeToast("Copied notations", duration: 1.5, position: .bottom, image: UIImage(named: "copy-icon-white"))
        }
    }

    public func cut() {
        self.superview!.hideAllToasts()
        print("Cut")
        if !self.selectedNotations.isEmpty {
            Clipboard.instance.cut(self.selectedNotations)
            self.selectedNotations.removeAll()
            self.updateMeasureDraw()
            self.superview!.makeToast("Cut notations", duration: 1.5, position: .bottom, image: UIImage(named: "cut-icon-white"))
        } else if let hovered = self.hoveredNotation {
            Clipboard.instance.cut([hovered])
            self.selectedNotations.removeAll()
            self.updateMeasureDraw()
            self.superview!.makeToast("Cut notations", duration: 1.5, position: .bottom, image: UIImage(named: "cut-icon-white"))
        }
        

    }
    
    public func paste() {
        selectedNotations.removeAll()
        
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
                
                EventBroadcaster.instance.postEvent(event: EventNames.ADD_GRAND_STAFF)
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
                    
                    EventBroadcaster.instance.postEvent(event: EventNames.ADD_GRAND_STAFF)
                }
            } else {
                Clipboard.instance.paste(measures: measures, at: startMeasure.notationObjects.count)
                
                EventBroadcaster.instance.postEvent(event: EventNames.ADD_GRAND_STAFF)
            }
        }
        
        
        
        self.updateMeasureDraw()
        
        //Clipboard.instance.paste(measures: <#T##[Measure]#>, noteIndex: &<#T##Int#>)
    }

    public func play() {
        print("Play")

        if !SoundManager.instance.isPlaying {
            
            sheetCursor.yVisible = false
            sheetCursor.xVisible = false
            
            if let composition = self.composition {
                SoundManager.instance.musicPlayback(composition)

                if #available(iOS 10.0, *) {
                    playBackTimer = Timer.scheduledTimer(withTimeInterval: 60 / SoundManager.instance.tempo * 0.0625, repeats: true) { _ in
                        self.updateTime()
                    }
                } else {
                    playBackTimer = Timer.scheduledTimer(timeInterval: 60 / SoundManager.instance.tempo * 0.0625,
                                         target: self,
                                         selector: #selector(self.updateTime),
                                         userInfo: nil,
                                         repeats: true)
                }

                RunLoop.main.add(playBackTimer, forMode: RunLoopMode.commonModes)

                self.isUserInteractionEnabled = false
            }
        } else {
            SoundManager.instance.stopPlaying()
            playBackTimer.invalidate()
            
            self.enableInteraction()
            
        }

    }

    func enableInteraction() {
        self.isUserInteractionEnabled = true
        
        self.sheetCursor.yVisible = true
        self.sheetCursor.xVisible = true
        
        self.playbackHighlightRect.path = nil
    }

    @objc
    func updateTime() {
        //TODO: IMPLEMENT PLAYBACK FRONTEND

        /*let xIterate: CGFloat = CGFloat(SoundManager.instance.tempo / 10)

        sheetCursor.moveCursorX(location: CGPoint(x: sheetCursor.curXCursorLocation.x + xIterate, y: sheetCursor.curXCursorLocation.y))*/

    }

    private func highlightParallelMeasures(parameters: Parameters) {
        let currentPlayingMeasure:Measure = parameters.get(key: KeyNames.HIGHLIGHT_MEASURE) as! Measure

        if let composition = self.composition {
            if let measureIndex = composition.staffList[0].measures.index(of: currentPlayingMeasure) {

                let parallelPlayingMeasure: Measure = composition.staffList[1].measures[measureIndex]

                if let gMeasurePoints = GridSystem.instance.getPointsFromMeasure(measure: currentPlayingMeasure),
                   let fMeasurePoints = GridSystem.instance.getPointsFromMeasure(measure: parallelPlayingMeasure) {
                
                    scrollMusicSheetToY(y: gMeasurePoints.lowerRightPointWithLedger.y)
                    scrollMusicSheetToX(x: gMeasurePoints.upperLeftPoint.x - 140)
                    
                    let r: CGRect = CGRect(x: fMeasurePoints.upperLeftPoint.x, y: fMeasurePoints.upperLeftPoint.y,
                            width: gMeasurePoints.width,
                            height: gMeasurePoints.lowerRightPoint.y - fMeasurePoints.lowerRightPoint.y + gMeasurePoints.height)

                    let path = CGPath(rect: r, transform: nil)
                    playbackHighlightRect.path = path

                    let highlightColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.3)
                    playbackHighlightRect.fillColor = highlightColor.cgColor
                    
                    self.layer.addSublayer(playbackHighlightRect)
                }

            }
        }

    }

    /*public func editTimeSig(params: Parameters) {
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
                        if staff.measures[i].timeSignature == oldTimeSig {
                            let curMeasure = staff.measures[i]

                            /*while newMaxBeatValue < curMeasure.getTotalBeats() {
                                curMeasure.deleteInMeasure(curMeasure.notationObjects[curMeasure.notationObjects.count - 1])
                            }*/

                            staff.measures[i].timeSignature = newMeasure.timeSignature
                            //staff.measures[i].fillWithRests()
                        }
                    }
                }
            }
        }

        var oldStaffs = [Staff]()

        var oldStaffsNotations = [[MusicNotation]]()

        if let staffs = composition?.staffList {
            for staff in staffs {
                oldStaffs.append(staff.duplicate())
            }
        }

        for oldStaff in oldStaffs {
            oldStaffsNotations.append([MusicNotation]())
        }

        var oldStaffIndex = 0

        for oldStaff in oldStaffs {
            for measure in oldStaff.measures {
                for notation in measure.notationObjects {
                    oldStaffsNotations[oldStaffIndex].append(notation)
                }
            }

            oldStaffIndex += 1
        }

        if let staffs = composition?.staffList {
            for staff in staffs {
                for measure in staff.measures {
                    measure.removeAllNotations()
                }
            }
        }

        var index = 0

        if let staffs = composition?.staffList {
            for (staff, notations) in zip(staffs, oldStaffsNotations) {
                for measure in staff.measures {
                    while index < notations.count && measure.add(notations[index]) {
                        index += 1
                    }

                    measure.fillWithRests()
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
                            print("staff.measures[i].keySignature.toString()")
                        }
                    }
                }
            }
        }
    }*/
    
    func editSignature(params: Parameters) {
        let startMeasure = params.get(key: KeyNames.START_MEASURE) as! Measure
        let oldKeySignature = params.get(key: KeyNames.OLD_KEY_SIGNATURE) as! KeySignature
        let newKeySignature = params.get(key: KeyNames.NEW_KEY_SIGNATURE) as! KeySignature
        let oldTimeSignature = params.get(key: KeyNames.OLD_TIME_SIGNATURE) as! TimeSignature
        let newTimeSignature = params.get(key: KeyNames.NEW_TIME_SIGNATURE) as! TimeSignature
        
        var stavesToEdit = [Staff]()
    
        var startIndex = 0
        
        if let staves = self.composition?.staffList {
            for staff in staves {
                if let start = staff.measures.index(of: startMeasure) {
                    startIndex = start
                }
            }
            
            for staff in staves {
                let measures = Array(staff.measures[startIndex...])
                stavesToEdit.append(Staff(measures: measures))
            }
        }
        
        let editSignatureAction = EditSignatureAction(staves: stavesToEdit,
                                                      oldKeySignature: oldKeySignature,
                                                      newKeySignature: newKeySignature,
                                                      oldTimeSignature: oldTimeSignature,
                                                      newTimeSignature: newTimeSignature)
        
        editSignatureAction.execute()
        self.updateMeasureDraw()
        self.moveCursorsToNearestSnapPoint(location: sheetCursor.curYCursorLocation)
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
            if !sameAccidentals(notations: self.selectedNotations, accidental: .natural) {
                for (index, note) in self.selectedNotations.enumerated() {
                    if note is Note {
                        let curNote = note as! Note

                        let newNote = curNote.duplicate()
                        newNote.accidental = .natural

                        self.selectedNotations[index] = newNote

                        let editAction = EditAction(old: [curNote], new: [newNote])

                        editAction.execute()

                        self.updateMeasureDraw()
                    }
                }
            } else {
                for (index, note) in self.selectedNotations.enumerated() {
                    if note is Note {
                        let curNote = note as! Note

                        let newNote = curNote.duplicate()
                        newNote.accidental = nil

                        self.selectedNotations[index] = newNote

                        let editAction = EditAction(old: [curNote], new: [newNote])

                        editAction.execute()

                        self.updateMeasureDraw()
                    }
                }
            }

        } else if let hovered = self.hoveredNotation {
            if let curNote = hovered as? Note {
                let newNote = curNote.duplicate()

                if curNote.accidental != .natural {
                    newNote.accidental = .natural
                } else {
                    newNote.accidental = nil
                }

                let editAction = EditAction(old: [curNote], new: [newNote])

                editAction.execute()

                self.updateMeasureDraw()
            }
        }

    }

    public func flat() {
        if !self.selectedNotations.isEmpty {
            if !sameAccidentals(notations: self.selectedNotations, accidental: .flat) {
                for (index, note) in self.selectedNotations.enumerated() {
                    if note is Note {
                        let curNote = note as! Note

                        let newNote = curNote.duplicate()
                        newNote.accidental = .flat

                        self.selectedNotations[index] = newNote

                        let editAction = EditAction(old: [curNote], new: [newNote])

                        editAction.execute()

                        self.updateMeasureDraw()
                    }
                }
            } else {
                for (index, note) in self.selectedNotations.enumerated() {
                    if note is Note {
                        let curNote = note as! Note

                        let newNote = curNote.duplicate()
                        newNote.accidental = nil

                        self.selectedNotations[index] = newNote

                        let editAction = EditAction(old: [curNote], new: [newNote])

                        editAction.execute()

                        self.updateMeasureDraw()
                    }
                }
            }

        } else if let hovered = self.hoveredNotation {
            if let curNote = hovered as? Note {
                let newNote = curNote.duplicate()

                if curNote.accidental != .flat {
                    newNote.accidental = .flat
                } else {
                    newNote.accidental = nil
                }

                let editAction = EditAction(old: [curNote], new: [newNote])

                editAction.execute()

                self.updateMeasureDraw()
            }
        }

    }

    func sameAccidentals(notations: [MusicNotation], accidental: Accidental) -> Bool {
        var accidentalCount = 0

        for notation in notations {
            if let note = notation as? Note {
                if accidental == .sharp {
                    if note.accidental == .sharp {
                        accidentalCount += 1
                    }
                } else if accidental == .natural {
                    if note.accidental == .natural {
                        accidentalCount += 1
                    }
                } else if accidental == .flat {
                    if note.accidental == .flat {
                        accidentalCount += 1
                    }
                } else if accidental == .doubleSharp {
                    if note.accidental == .doubleSharp {
                        accidentalCount += 1
                    }
                }
            } else {
                return false
            }
        }

        return accidentalCount == notations.count
    }

    public func sharp() {
        if !self.selectedNotations.isEmpty {
            if !sameAccidentals(notations: self.selectedNotations, accidental: .sharp) {
                for (index, note) in self.selectedNotations.enumerated() {
                    if note is Note {
                        let curNote = note as! Note

                        let newNote = curNote.duplicate()
                        newNote.accidental = .sharp

                        self.selectedNotations[index] = newNote

                        let editAction = EditAction(old: [curNote], new: [newNote])

                        editAction.execute()

                        self.updateMeasureDraw()
                    }
                }
            } else {
                for (index, note) in self.selectedNotations.enumerated() {
                    if note is Note {
                        let curNote = note as! Note

                        let newNote = curNote.duplicate()
                        newNote.accidental = nil

                        self.selectedNotations[index] = newNote

                        let editAction = EditAction(old: [curNote], new: [newNote])

                        editAction.execute()

                        self.updateMeasureDraw()
                    }
                }
            }

        } else if let hovered = self.hoveredNotation {
            if let curNote = hovered as? Note {
                let newNote = curNote.duplicate()

                if curNote.accidental != .sharp {
                    newNote.accidental = .sharp
                } else {
                    newNote.accidental = nil
                }
                
                let editAction = EditAction(old: [curNote], new: [newNote])

                editAction.execute()

                self.updateMeasureDraw()
            }
        }

    }

    public func dsharp() {
        if !self.selectedNotations.isEmpty {
            if !sameAccidentals(notations: self.selectedNotations, accidental: .doubleSharp) {
                for (index, note) in self.selectedNotations.enumerated() {
                    if note is Note {
                        let curNote = note as! Note

                        let newNote = curNote.duplicate()
                        newNote.accidental = .doubleSharp

                        self.selectedNotations[index] = newNote

                        let editAction = EditAction(old: [curNote], new: [newNote])

                        editAction.execute()

                        self.updateMeasureDraw()
                    }
                }
            } else {
                for (index, note) in self.selectedNotations.enumerated() {
                    if note is Note {
                        let curNote = note as! Note

                        let newNote = curNote.duplicate()
                        newNote.accidental = nil

                        self.selectedNotations[index] = newNote

                        let editAction = EditAction(old: [curNote], new: [newNote])

                        editAction.execute()

                        self.updateMeasureDraw()
                    }
                }
            }

        } else if let hovered = self.hoveredNotation {
            if let curNote = hovered as? Note {
                let newNote = curNote.duplicate()

                if curNote.accidental != .doubleSharp {
                    newNote.accidental = .doubleSharp
                } else {
                    newNote.accidental = nil
                }

                let editAction = EditAction(old: [curNote], new: [newNote])

                editAction.execute()

                self.updateMeasureDraw()
            }
        }

    }

    func retrograde(notations: [MusicNotation]) {
        var retrograde = [MusicNotation]()

        for arrayIndex in stride(from: notations.count - 1, through: 0, by: -1) {
            retrograde.append(notations[arrayIndex].duplicate())
        }

        let editAction = EditAction(old: notations, new: retrograde)

        editAction.execute()

        self.updateMeasureDraw()

        selectedNotations.removeAll()
    }

    public func inverseSelected() {
        if selectedNotations.count > 1 {
            inverse(notations: selectedNotations)
        }
    }

    public func retrogradeSelected() {
        if selectedNotations.count > 1 {
            retrograde(notations: selectedNotations)
        }
    }

    func inverse(notations: [MusicNotation]) {
        var invertedDeltas = [Int]()
        var invertedNotes = [Note]()

        for x in 0...notations.count - 2 {
            print("XXX: \(x)")
            if notations[0] is Note && notations[x + 1] is Note {
                
                let delta = getNoteDifference(note1: notations[0] as! Note, note2: notations[x + 1] as! Note)
                
                print("DELTA: \(delta)")

                let invertDelta = delta * -1

                invertedDeltas.append(invertDelta)
            }
        }

        print("INVERTED DELTAS: \(invertedDeltas)")
        
        for y in 1...notations.count - 1 {
            if notations[y] is Note {
                let invertedNote = invertNote(note: notations[y].duplicate() as! Note, steps: invertedDeltas[y - 1])
                
                invertedNotes.append(invertedNote)

                print("inverted note pitch: \(invertedNote.pitch.step.rawValue)")
                print("inverted note octave: \(invertedNote.pitch.octave)")
            }
        }
        
        let oldNotes = Array(notations[1..<notations.count])
        
        print("OLD NOTES COUNT: \(oldNotes.count)")
        
        let editAction = EditAction(old: oldNotes, new: invertedNotes)
        
        editAction.execute()
        
        self.updateMeasureDraw()

        self.selectedNotations.removeAll()
    }

    func invertNote(note: Note, steps: Int) -> Note {

        var invertedNote = note
        
        print("INVERTNOTE STEPS: \(abs(steps))")
        print("STEPS: \(steps))")

        if abs(steps) > 0 {
            for _ in 1...abs(steps) * 2 {
                if steps > 0 {
                    invertedNote.transposeUp()
                } else if steps < 0 {
                    invertedNote.transposeDown()
                }
            }
        }

        return invertedNote
    }

    func allNotes(notations: [MusicNotation]) -> Bool {
        for notation in notations {
            if notation is Rest || notation is Chord {
                return false
            }
        }

        return true
    }

    func getNoteDifference(note1: Note, note2: Note) -> Int {
        print("note1 pitch : \(note1.pitch.step.rawValue) note2 pitch: \(note2.pitch.step.rawValue)")
        print("note1 octave: \(note1.pitch.octave) note2 octave: \(note2.pitch.octave)")
        return ((note2.pitch.octave * 7) + note2.pitch.step.rawValue) - ((note1.pitch.octave * 7) + note1.pitch.step.rawValue)
    }

}
