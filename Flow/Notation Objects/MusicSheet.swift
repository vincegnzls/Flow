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

@IBDesignable
class MusicSheet: UIView {

    private let HIGHLIGHTED_NOTES_TAG = 2500
    private let TIME_SIGNATURES_TAG = 2501
    
    private var executeLock = false
    private var newlyOpened = true
    
    private var dotModes = [false, false, false] {
        didSet {
            let dotMode = self.getCurrentDotMode()
            
            if let currentMeasure = GridSystem.instance.getCurrentMeasure() {
                currentMeasure.updateInvalidNotes(invalidNotes: currentMeasure.getInvalidNotes(numDots: dotMode))
            }
        }
    }

    private var ottavaMode: OttavaType? = nil {
        didSet {
            checkHighlightOttavaButton()
        }
    }

    private var accidentalMode: Accidental? = nil {
        didSet {
            checkHighlightAccidentalButton()
        }
    }

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
    
    @IBOutlet var transformView: UIView!
    @IBOutlet var riView: UIView!
    
    public var composition: Composition?
    public var hoveredNotation: MusicNotation? {
        didSet {
            checkHighlightAccidentalButton()
            checkHighlightOttavaButton()
            let parameters = Parameters()

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
                
                parameters.put(key: KeyNames.CURRENT_DOT_MODES, value: dotModes)
                
                //EventBroadcaster.instance.postEvent(event: EventNames.REMOVE_ACCIDENTAL_HIGHLIGHT)
                //disable accidentals
                //EventBroadcaster.instance.postEvent(event: EventNames.DISABLE_ACCIDENTALS)
            }
            
            parameters.put(key: KeyNames.SELECTED_NOTATIONS, value: [hoveredNotation])
            EventBroadcaster.instance.postEvent(event: EventNames.UPDATE_INVALID_DOTS, params: parameters)
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
            checkHighlightOttavaButton()
            print("SELECTED NOTES COUNT: " + String(selectedNotations.count))
            
            let parameters = Parameters() // parameters for dotted notes
            
            if selectedNotations.count == 0 {
                
                sheetCursor.showCursors()
                
                parameters.put(key: KeyNames.CURRENT_DOT_MODES, value: dotModes)

                self.transformView.isHidden = true

                /*if let measureCoord = GridSystem.instance.selectedMeasureCoord {
                    if let newMeasure = GridSystem.instance.getMeasureFromPoints(measurePoints: measureCoord) {
                        let params:Parameters = Parameters()
                        params.put(key: KeyNames.NEW_MEASURE, value: newMeasure)

                        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_SWITCHED, params: params)
                        //EventBroadcaster.instance.postEvent(event: EventNames.DISABLE_ACCIDENTALS)
                    }
                }*/

                //EventBroadcaster.instance.postEvent(event: EventNames.DISABLE_ACCIDENTALS)
            } else {
                selectedNotes()

                sheetCursor.hideCursors()
                //let params = Parameters()

                print("NANI")

                var allChordsSelected = [Chord]()
                
                for notation in selectedNotations {
                    if let note = notation as? Note {
                        if let chord = note.chord {
                            if !allChordsSelected.contains(chord) {
                                allChordsSelected.append(chord)
                            }
                        }
                    }
                }
                
                for (index, chord) in allChordsSelected.enumerated() {
                    var mustMeetNum = chord.notes.count
                    var currentNum = 0
                    
                    var possiblyRemovedNotes = [Note]()
                    
                    for notation in selectedNotations {
                        if let note = notation as? Note {
                            if chord.notes.contains(note) {
                                currentNum += 1
                                possiblyRemovedNotes.append(note)
                            }
                        }
                    }
                    
                    if mustMeetNum == currentNum {
                        for note in possiblyRemovedNotes {
                            if let index = selectedNotations.index(of: note) {
                                selectedNotations.remove(at: index)
                            }
                        }
                        
                        selectedNotations.append(chord)
                    }
                }
                
                if let coord = selectedNotations.last?.screenCoordinates {
                    self.transformView.frame = CGRect(x: coord.x + 60, y: coord.y - 53, width: transformView.frame.width, height: transformView.frame.height)
                    self.transformView.isHidden = false
                    self.addSubview(self.transformView)
                }

                if selectedNotations.count > 1 {
                    //let params = Parameters()

                    if allNotes(notations: selectedNotations) {
                        self.riView.isHidden = false
                    } else {
                        self.riView.isHidden = true
                    }
                } else {
                    self.riView.isHidden = true
                }
                //EventBroadcaster.instance.postEvent(event: EventNames.ENABLE_ACCIDENTALS)
            }
            
            parameters.put(key: KeyNames.SELECTED_NOTATIONS, value: selectedNotations)
            EventBroadcaster.instance.postEvent(event: EventNames.UPDATE_INVALID_DOTS, params: parameters)
            
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

    func drawCurvedLine(from: CGPoint, to: CGPoint, thickness: CGFloat, bendFactor: CGFloat) {

        let center = CGPoint(x: (from.x+to.x)*0.5, y: (from.y+to.y)*0.5)
        let normal = CGPoint(x: -(from.y-to.y), y: (from.x-to.x))
        let normalNormalized: CGPoint = {
            let normalSize = sqrt(normal.x*normal.x + normal.y*normal.y)
            guard normalSize > 0.0 else { return .zero }
            return CGPoint(x: normal.x/normalSize, y: normal.y/normalSize)
        }()

        let path = UIBezierPath()

        path.move(to: from)

        let multiplier: CGFloat = 3.5

        let midControlPoint: CGPoint = CGPoint(x: center.x + normal.x * bendFactor, y: center.y + normal.y * bendFactor)
        let closeControlPoint: CGPoint = CGPoint(x: midControlPoint.x + normalNormalized.x * thickness * multiplier, y: midControlPoint.y + normalNormalized.y * thickness * multiplier)
        let farControlPoint: CGPoint = CGPoint(x: midControlPoint.x - normalNormalized.x * thickness * multiplier, y: midControlPoint.y - normalNormalized.y * thickness * multiplier)


        path.addQuadCurve(to: to, controlPoint: closeControlPoint)
        path.addQuadCurve(to: from, controlPoint: farControlPoint)
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = thickness
        shapeLayer.path = path.cgPath
        shapeLayer.zPosition = .greatestFiniteMagnitude

        self.layer.addSublayer(shapeLayer)
        self.curLayers.append(shapeLayer)
    }

    func downward(notes: [Note]) -> Bool {

        var down = 0
        var up = 0

        for note in notes {
            if note.isUpwards {
                up += 1
            } else {
                down += 1
            }
        }

        return down >= up
    }

    func drawConnection(connection: Connection, bendFactor: CGFloat, isChord: Bool) {
        print("DRAW CONNECTION")

        if let first = connection.getFirstNote() {
            if let last = connection.getLastNote() {

                if let firstCoord = first.screenCoordinates {
                    if let lastCoord = last.screenCoordinates {

                        let offset: CGFloat = 22

                        if !isChord {

                            if let notes = connection.notes {

                                if downward(notes: notes) {
                                    let adjustedFirst = CGPoint(x: firstCoord.x + offset, y: firstCoord.y - offset + 8)
                                    let adjustedLast = CGPoint(x: lastCoord.x + offset, y: lastCoord.y - offset + 8)
                                    drawCurvedLine(from: adjustedFirst, to: adjustedLast, thickness: 1, bendFactor: bendFactor)
                                } else {
                                    let adjustedFirst = CGPoint(x: firstCoord.x + offset, y: firstCoord.y + offset - 5)
                                    let adjustedLast = CGPoint(x: lastCoord.x + offset, y: lastCoord.y + offset - 5)
                                    drawCurvedLine(from: adjustedFirst, to: adjustedLast, thickness: 1, bendFactor: bendFactor * -1)
                                }
                            }
                        } else {

                        }

                    }
                }
            }
        }
    }

    func checkConnectionPerMeasure(notations: [MusicNotation]) {
        for notation in notations {
            if let note = notation as? Note {
                if let connection = note.connection {
                    if let first = notations.first {
                        if note == first {
                            drawConnection(connection: connection, bendFactor: 0.25, isChord: false)
                        }
                    }
                }
            } else if let chord = notation as? Chord {

            }
        }
    }

    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, thickness: CGFloat) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = thickness
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.

        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        shapeLayer.zPosition = .greatestFiniteMagnitude
        self.layer.addSublayer(shapeLayer)
        self.curLayers.append(shapeLayer)
    }

    func checkOttavaPerMeasure(notations: [MusicNotation]) {
        var curGroup = [Note]()

        for notation in notations {
            if let note = notation as? Note {
                if let ottava = note.ottava {
                    if !curGroup.isEmpty {
                        if curGroup[0].ottava == ottava {
                            curGroup.append(note)
                        } else {
                            if curGroup.count == 1 {
                                if let coord = curGroup[0].screenCoordinates {
                                    if let ottava = curGroup[0].ottava {
                                        if let measure = curGroup[0].measure {
                                            drawOttava(start: coord, end: coord, type: ottava, clef: measure.clef, notations: curGroup)
                                            print("draw 1")
                                        }
                                    }
                                }
                            } else if curGroup.count > 1 {
                                if let first = curGroup.first {
                                    if let last = curGroup.last {
                                        if let firstCoord = first.screenCoordinates {
                                            if let lastCoord = last.screenCoordinates {
                                                if let firstOttava = first.ottava {
                                                    if let measure = first.measure {
                                                        drawOttava(start: firstCoord, end: lastCoord, type: firstOttava, clef: measure.clef, notations: curGroup)
                                                        print("draw 2")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            curGroup.removeAll()
                            curGroup.append(note)
                        }
                    } else {
                        curGroup.append(note)
                    }
                } else {
                    if curGroup.count == 1 {
                        if let coord = curGroup[0].screenCoordinates {
                            if let ottava = curGroup[0].ottava {
                                if let measure = curGroup[0].measure {
                                    drawOttava(start: coord, end: coord, type: ottava, clef: measure.clef, notations: curGroup)
                                    curGroup.removeAll()
                                    print("draw 3")
                                }
                            }
                        }
                    } else if curGroup.count > 1 {
                        if let first = curGroup.first {
                            if let last = curGroup.last {
                                if let firstCoord = first.screenCoordinates {
                                    if let lastCoord = last.screenCoordinates {
                                        if let firstOttava = first.ottava {
                                            if let measure = first.measure {
                                                drawOttava(start: firstCoord, end: lastCoord, type: firstOttava, clef: measure.clef, notations: curGroup)
                                                curGroup.removeAll()
                                                print("draw 4")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                //curGroup.removeAll()
            } else {
                if let chord = notation as? Chord {
                    if let ottava = chord.ottava {
                        if !curGroup.isEmpty {
                            if curGroup[0].ottava == ottava {
                                curGroup.append(chord.notes[0])
                            } else {
                                if curGroup.count == 1 {
                                    if let coord = curGroup[0].screenCoordinates {
                                        if let ottava = curGroup[0].ottava {
                                            if let measure = curGroup[0].measure {
                                                drawOttava(start: coord, end: coord, type: ottava, clef: measure.clef, notations: curGroup)
                                                print("draw 5")
                                            }
                                        }
                                    }
                                } else if curGroup.count > 1 {
                                    if let first = curGroup.first {
                                        if let last = curGroup.last {
                                            if let firstCoord = first.screenCoordinates {
                                                if let lastCoord = last.screenCoordinates {
                                                    if let firstOttava = first.ottava {
                                                        if let measure = first.measure {
                                                            drawOttava(start: firstCoord, end: lastCoord, type: firstOttava, clef: measure.clef, notations: curGroup)
                                                            print("draw 6")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                curGroup.removeAll()
                                curGroup.append(chord.notes[0])
                            }
                        } else {
                            curGroup.append(chord.notes[0])
                        }
                    } else {
                        if curGroup.count == 1 {
                            if let coord = curGroup[0].screenCoordinates {
                                if let ottava = curGroup[0].ottava {
                                    if let measure = curGroup[0].measure {
                                        drawOttava(start: coord, end: coord, type: ottava, clef: measure.clef, notations: curGroup)
                                        curGroup.removeAll()
                                        print("draw 7")
                                    }
                                }
                            }
                        } else if curGroup.count > 1 {
                            if let first = curGroup.first {
                                if let last = curGroup.last {
                                    if let firstCoord = first.screenCoordinates {
                                        if let lastCoord = last.screenCoordinates {
                                            if let firstOttava = first.ottava {
                                                if let measure = first.measure {
                                                    drawOttava(start: firstCoord, end: lastCoord, type: firstOttava, clef: measure.clef, notations: curGroup)
                                                    curGroup.removeAll()
                                                    print("draw 8")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        //curGroup.removeAll()
                    }
                }
            }
        }

        if curGroup.count == 1 {
            if let coord = curGroup[0].screenCoordinates {
                if let ottava = curGroup[0].ottava {
                    if let measure = curGroup[0].measure {
                        drawOttava(start: coord, end: coord, type: ottava, clef: measure.clef, notations: curGroup)
                        curGroup.removeAll()
                        print("draw 9")
                    }
                }
            }
        } else if curGroup.count > 1 {
            if let first = curGroup.first {
                if let last = curGroup.last {
                    if let firstCoord = first.screenCoordinates {
                        if let lastCoord = last.screenCoordinates {
                            if let firstOttava = first.ottava {
                                if let measure = first.measure {
                                    drawOttava(start: firstCoord, end: lastCoord, type: firstOttava, clef: measure.clef, notations: curGroup)
                                    curGroup.removeAll()
                                    print("draw 10")
                                }
                            }
                        }
                    }
                }
            }
        }
        //curGroup.removeAll()
    }

    func getHigherOrLowerY(start: CGFloat, end: CGFloat, higher: Bool, notations: [MusicNotation]) -> CGFloat {
        var highestOrLowestNote = getLowestOrHighestNote(highest: higher, notations: notations)

        if let coord = highestOrLowestNote.screenCoordinates {
            if higher {
                if coord.y - 40 > 65 {
                    return 65
                } else {
                    return coord.y - 40
                }
            } else {
                if coord.y + 40 < 565 {
                    return 565
                } else {
                    return coord.y + 40
                }
            }
        }

        return 0.0
    }

    func drawOttava(start: CGPoint, end: CGPoint, type: OttavaType, clef: Clef, notations: [MusicNotation]) {
        let adjustedStart = CGPoint(x: start.x + 50, y: getHigherOrLowerY(start: start.y, end: end.y, higher: clef == .G, notations: notations))
        let adjustedEnd = CGPoint(x: end.x + 50, y: getHigherOrLowerY(start: start.y, end: end.y, higher: clef == .G, notations: notations))

        if start.equalTo(end) {
            self.drawLine(start: adjustedStart, end: adjustedEnd, thickness: 2)
        } else {
            self.drawDottedLine(start: adjustedStart, end: adjustedEnd, thickness: 2)
        }

        if clef == .G {
            self.drawLine(start: adjustedEnd, end: CGPoint(x: adjustedEnd.x, y: adjustedEnd.y + 20), thickness: 2)
        } else {
            self.drawLine(start: adjustedEnd, end: CGPoint(x: adjustedEnd.x, y: adjustedEnd.y - 20), thickness: 2)
        }

        if type == .eightVa {
            let ottavaImage = UIImage(named: "8va")

            let ottavaView = UIImageView(frame: CGRect(x: adjustedStart.x - 50, y: adjustedStart.y - 22.5, width: 50, height: 45))
            ottavaView.image = ottavaImage

            self.addSubview(ottavaView)
        } else if type == .eightVb {
            let ottavaImage = UIImage(named: "8vb")

            let ottavaView = UIImageView(frame: CGRect(x: adjustedStart.x - 50, y: adjustedStart.y - 22.5, width: 50, height: 45))
            ottavaView.image = ottavaImage

            self.addSubview(ottavaView)
        } else if type == .fifteenMa {
            let ottavaImage = UIImage(named: "15ma")

            let ottavaView = UIImageView(frame: CGRect(x: adjustedStart.x - 50, y: adjustedStart.y - 22.5, width: 50, height: 45))
            ottavaView.image = ottavaImage

            self.addSubview(ottavaView)
        } else if type == . fifteenMb {
            let ottavaImage = UIImage(named: "15mb")

            let ottavaView = UIImageView(frame: CGRect(x: adjustedStart.x - 50, y: adjustedStart.y - 22.5, width: 50, height: 45))
            ottavaView.image = ottavaImage

            self.addSubview(ottavaView)
        }
    }

    func repositionTransformView(first: Bool) {
        if first {
            if let coord = selectedNotations.first?.screenCoordinates {
                self.transformView.frame = CGRect(x: coord.x + 60, y: coord.y - 53, width: transformView.frame.width, height: transformView.frame.height)
            }
        } else {
            if let coord = selectedNotations.last?.screenCoordinates {
                self.transformView.frame = CGRect(x: coord.x + 60, y: coord.y - 53, width: transformView.frame.width, height: transformView.frame.height)
            }
        }

        self.transformView.isHidden = false
        self.addSubview(self.transformView)
        self.transformView.superview?.bringSubview(toFront: self.transformView)
        self.transformView.layer.zPosition = CGFloat.greatestFiniteMagnitude
    }

    func checkHighlightOttavaButton() -> OttavaType? {
        var ottava: OttavaType? = nil
        var params = Parameters()

        if !self.selectedNotations.isEmpty {
            if sameOttava(notations: self.selectedNotations) {
                for notation in self.selectedNotations {
                    if let note = notation as? Note {
                        if ottava == nil {
                            ottava = note.ottava
                        } else {
                            if note.ottava != nil {
                                params.put(key: KeyNames.OTTAVA, value: ottava)
                                EventBroadcaster.instance.postEvent(event: EventNames.OTTAVA_HIGHLIGHT, params: params)
                                return ottava
                            }
                        }
                    } else if let chord = notation as? Chord {
                        if ottava == nil {
                            ottava = chord.ottava
                        } else {
                            if chord.ottava != nil {
                                params.put(key: KeyNames.OTTAVA, value: ottava)
                                EventBroadcaster.instance.postEvent(event: EventNames.OTTAVA_HIGHLIGHT, params: params)
                                return ottava
                            }
                        }
                    }
                }

                if selectedNotations.count == 1 {
                    if ottava != nil {
                        params.put(key: KeyNames.OTTAVA, value: ottava)
                        EventBroadcaster.instance.postEvent(event: EventNames.OTTAVA_HIGHLIGHT, params: params)
                    }
                }
            } else {
                EventBroadcaster.instance.postEvent(event: EventNames.REMOVE_OTTAVA_HIGHLIGHT)
            }
        } else if let notation = self.hoveredNotation {
            if let note = notation as? Note {
                if note.ottava != nil {
                    params.put(key: KeyNames.OTTAVA, value: note.ottava)
                    EventBroadcaster.instance.postEvent(event: EventNames.OTTAVA_HIGHLIGHT, params: params)
                    return ottava
                }
            } else if let chord = notation as? Chord {
                params.put(key: KeyNames.OTTAVA, value: chord.ottava)
                EventBroadcaster.instance.postEvent(event: EventNames.OTTAVA_HIGHLIGHT, params: params)
                return ottava
            }
        } else if let ottavaMode = self.ottavaMode {
            params.put(key: KeyNames.OTTAVA, value: ottavaMode)
            EventBroadcaster.instance.postEvent(event: EventNames.OTTAVA_HIGHLIGHT, params: params)
            return ottava
        } else {
            EventBroadcaster.instance.postEvent(event: EventNames.REMOVE_OTTAVA_HIGHLIGHT)
        }

        return ottava
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

            if let accidentalMode = self.accidentalMode {
                params.put(key: KeyNames.ACCIDENTAL, value: accidentalMode)
                EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, params: params)
            }
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

                if let accidentalMode = self.accidentalMode {
                    params.put(key: KeyNames.ACCIDENTAL, value: accidentalMode)
                    EventBroadcaster.instance.postEvent(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, params: params)
                }
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
        EventBroadcaster.instance.removeObservers(event: EventNames.ACCIDENTAL_PRESS)
        EventBroadcaster.instance.addObserver(event: EventNames.ACCIDENTAL_PRESS, observer: Observer(id: "MusicSheet.accidentalPress", function: self.accidentalPress))
        
        // Add listeners for dots
        EventBroadcaster.instance.removeObservers(event: EventNames.DOT_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.DOT_KEY_PRESSED, observer: Observer(id: "MusicSheet.dotNotation", function: self.dotNotation))

        EventBroadcaster.instance.removeObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "MusicSheet.enableInteraction", function: self.enableInteraction))
        EventBroadcaster.instance.addObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "MusicSheet.enableInteraction", function: self.enableInteraction))

        EventBroadcaster.instance.removeObservers(event: EventNames.HIGHLIGHT_MEASURE)
        EventBroadcaster.instance.addObserver(event: EventNames.HIGHLIGHT_MEASURE, observer: Observer(id: "MusicSheet.highlightParallelMeasures", function: self.highlightParallelMeasures))
        
        EventBroadcaster.instance.removeObservers(event: EventNames.ACTION_PERFORMED)
        EventBroadcaster.instance.addObserver(event: EventNames.ACTION_PERFORMED, observer: Observer(id: "MusicSheet.redirectCursorOnAction", function: self.redirectCursorOnAction))

        // Add listeners for ottava
        EventBroadcaster.instance.removeObservers(event: EventNames.OTTAVA)
        EventBroadcaster.instance.addObserver(event: EventNames.OTTAVA, observer: Observer(id: "MusicSheet.ottava", function: self.ottava))

        // Add listeners for connection
        EventBroadcaster.instance.removeObservers(event: EventNames.CONNECTION)
        EventBroadcaster.instance.addObserver(event: EventNames.CONNECTION, observer: Observer(id: "MusicSheet.connection", function: self.connection))

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
            
            for notation in self.selectedNotations {
                self.highlightNotation(notation, false)
            }

        }
        
        if newlyOpened {
            self.remapCurrentMeasure(location: sheetCursor.curYCursorLocation)
            self.moveCursorsToNearestSnapPoint(location: sheetCursor.curYCursorLocation)
            
            newlyOpened = false
        }
        
        executeLock = false
        print("FINISHED DRAWING")
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

            checkOttavaPerMeasure(notations: measure.notationObjects)
            checkConnectionPerMeasure(notations: measure.notationObjects)
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

        var hasFlipped = false
        
        if let chord = notation as? Chord {
            
            var flipped = false
            
            for (index, note) in chord.notes.enumerated() {
                
                if let screenCoordinates = note.screenCoordinates, let image = note.image {
                    
                    if index > 0 {
                        if Pitch.difference(from: note.pitch, to: chord.notes[index-1].pitch) == 1 && !flipped {
                            notationImageViews.append(
                                UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset + 24, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter)))
                            
                            flipped = true
                            hasFlipped = true
                        } else {
                            notationImageViews.append(
                                UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter)))
                            
                            flipped = false
                        }
                    } else {
                        notationImageViews.append(
                            UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter)))
                        
                        flipped = false
                    }
                    
                    if let measure = chord.measure {
                        if let measurePoints = GridSystem.instance.getPointsFromMeasure(measure: measure) {
                            drawLedgerLinesIfApplicable(measurePoints: measurePoints, upToLocation: screenCoordinates)
                        }
                    }
                }
                
            }
            
            /*for note in chord.notes {
                drawAccidentalByNote(note: note)
            }*/
            
            drawAccidentalByChord(chord: chord)
            drawDotsByNotation(notation: chord, hasFlipped: hasFlipped)
            
        } else if let note = notation as? Note {
            
            if let screenCoordinates = note.screenCoordinates, let image = note.image {
                
                notationImageViews.append(
                    UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter)))
                
                drawAccidentalByNote(note: note)
                drawDotsByNotation(notation: note)
                
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
            
            drawDotsByNotation(notation: rest)
            
        }

        for notationImageView in notationImageViews {
            notationImageView.image = notation.image
            
            self.addSubview(notationImageView)
        }
        
        if notation is Chord && notation.type != .whole{
            let chord = notation as? Chord
            drawChordLine(chord: chord!, hasFlipped: hasFlipped)
        }
        
    }
    
    private func noteGroupIsUpwards (notes: [Note]) -> Bool {
        
        var upCount: Int = 0
        var downCount: Int = 0
        
        for note in notes {
            if note.isUpwards {
                upCount += 1
            } else {
                downCount += 1
            }
        }
        
        return upCount > downCount
    }
    
    private func drawChordLine (chord: Chord, hasFlipped: Bool = false) {
        
        let stemHeight: CGFloat = 68
        
        let isUpwards = noteGroupIsUpwards(notes: chord.notes)
        
        let startNotePoint = chord.notes[0].screenCoordinates!
        let endNotePoint = chord.notes.last!.screenCoordinates!
        
        var startPoint = CGPoint(x: startNotePoint.x + noteXOffset + 1.515, y: startNotePoint.y)
        var endPoint = CGPoint(x: endNotePoint.x + noteXOffset + 1.515, y: endNotePoint.y)
        
        if isUpwards || hasFlipped {
            startPoint = CGPoint(x: startNotePoint.x + noteXOffset + 25, y: startNotePoint.y)
            endPoint = CGPoint(x: endNotePoint.x + noteXOffset + 25, y: endNotePoint.y)
        }
        
        let _ = drawLine(start: startPoint, end: endPoint, thickness: 2.3)
        
        var tailImageView: UIImageView?
        
        if chord.type == .quarter || chord.type == .half {
            if isUpwards { // upwards
                let newEndPoint = CGPoint(x: endPoint.x, y: endPoint.y - stemHeight)
                let _ = drawLine(start: endPoint, end: newEndPoint, thickness: 2.3)
            } else { // downwards
                let newEndPoint = CGPoint(x: startPoint.x, y: startPoint.y + stemHeight)
                let _ = drawLine(start: endPoint, end: newEndPoint, thickness: 2.3)
            }
        } else if chord.type == .eighth{
            if isUpwards {
                let newEndPoint = CGPoint(x: endPoint.x, y: endPoint.y - stemHeight)
                let _ = drawLine(start: endPoint, end: newEndPoint, thickness: 2.3)
                
                if let eighthTailImage = UIImage(named:"eighth-stem-up") {
                    tailImageView = UIImageView(frame: CGRect(x: endPoint.x + noteXOffset - 11, y: endPoint.y - stemHeight - 27, width: eighthTailImage.size.width, height: eighthTailImage.size.height))
                    
                    tailImageView?.image = eighthTailImage
                }
            } else {
                let newEndPoint = CGPoint(x: startPoint.x, y: startPoint.y + stemHeight + 5)
                let _ = drawLine(start: endPoint, end: newEndPoint, thickness: 2.3)
                
                if let eighthTailImage = UIImage(named:"eighth-stem-down") {
                    tailImageView = UIImageView(frame: CGRect(x: startPoint.x + noteXOffset - 11, y: startPoint.y + 13, width: eighthTailImage.size.width, height: eighthTailImage.size.height))
                    
                    tailImageView?.image = eighthTailImage
                }
            }
        } else if chord.type == .sixteenth {
            if isUpwards {
                let newEndPoint = CGPoint(x: endPoint.x, y: endPoint.y - stemHeight)
                let _ = drawLine(start: endPoint, end: newEndPoint, thickness: 2.3)
                
                if let sixteenthTailImage = UIImage(named:"16th-stem-up") {
                    tailImageView = UIImageView(frame: CGRect(x: endPoint.x + noteXOffset - 11, y: endPoint.y - stemHeight - 27, width: sixteenthTailImage.size.width, height: sixteenthTailImage.size.height))
                    
                    tailImageView?.image = sixteenthTailImage
                }
            } else {
                let newEndPoint = CGPoint(x: startPoint.x, y: startPoint.y + stemHeight + 15)
                let _ = drawLine(start: endPoint, end: newEndPoint, thickness: 2.3)
                
                if let sixteenthTailImage = UIImage(named:"16th-stem-down") {
                    tailImageView = UIImageView(frame: CGRect(x: startPoint.x + noteXOffset - 11, y: startPoint.y + 13, width: sixteenthTailImage.size.width, height: sixteenthTailImage.size.height))
                    
                    tailImageView?.image = sixteenthTailImage
                }
            }
        } else if chord.type == .thirtySecond {
            if isUpwards {
                let newEndPoint = CGPoint(x: endPoint.x, y: endPoint.y - stemHeight - 12)
                let _ = drawLine(start: endPoint, end: newEndPoint, thickness: 2.3)
                
                if let thirtySecondTailImage = UIImage(named:"32nd-stem-up") {
                    tailImageView = UIImageView(frame: CGRect(x: endPoint.x + noteXOffset - 11, y: endPoint.y - stemHeight - 27, width: thirtySecondTailImage.size.width, height: thirtySecondTailImage.size.height))
                    
                    tailImageView?.image = thirtySecondTailImage
                }
            } else {
                let newEndPoint = CGPoint(x: startPoint.x, y: startPoint.y + stemHeight + 27)
                let _ = drawLine(start: endPoint, end: newEndPoint, thickness: 2.3)
                
                if let thirtySecondTailImage = UIImage(named:"32nd-stem-down") {
                    tailImageView = UIImageView(frame: CGRect(x: startPoint.x + noteXOffset - 11, y: startPoint.y + 13, width: thirtySecondTailImage.size.width, height: thirtySecondTailImage.size.height))
                    
                    tailImageView?.image = thirtySecondTailImage
                }
            }
        } else if chord.type == .sixtyFourth {
            if isUpwards {
                let newEndPoint = CGPoint(x: endPoint.x, y: endPoint.y - stemHeight - 27)
                let _ = drawLine(start: endPoint, end: newEndPoint, thickness: 2.3)
                
                if let sixtyFourthTailImage = UIImage(named:"64th-stem-up") {
                    tailImageView = UIImageView(frame: CGRect(x: endPoint.x + noteXOffset - 11, y: endPoint.y - stemHeight - 27, width: sixtyFourthTailImage.size.width, height: sixtyFourthTailImage.size.height))
                    
                    tailImageView?.image = sixtyFourthTailImage
                }
            } else {
                let newEndPoint = CGPoint(x: startPoint.x, y: startPoint.y + stemHeight + 47)
                let _ = drawLine(start: endPoint, end: newEndPoint, thickness: 2.3)
                
                if let sixtyFourthTailImage = UIImage(named:"64th-stem-down") {
                    tailImageView = UIImageView(frame: CGRect(x: startPoint.x + noteXOffset - 11, y: startPoint.y + 13, width: sixtyFourthTailImage.size.width, height: sixtyFourthTailImage.size.height))
                    
                    tailImageView?.image = sixtyFourthTailImage
                }
            }
        }
        
        if let tailImageView = tailImageView {
            self.addSubview(tailImageView)
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
    
    private func drawAccidentalByChord (chord: Chord) {
        
        func drawAccidentalsZigzag (notes: [Note]) {
            var currentXModify: CGFloat = 0
            var accidentalImageViews = [UIImageView]()
            
            // also check if there is a difference between two notes that is > 5, this would restart the layout back nearest to the chord
            var backtracking = false
            for (index, note) in notes.enumerated() {
                
                if index != 0 {
                    if !backtracking{
                        if index < (notes.count/2) && notes.count > 4 {
                            currentXModify += 25
                        } else if notes.count > 2 && index != notes.count - 1 {
                            currentXModify += 50
                        } else {
                            currentXModify += 25
                        }
                    }
                    
                    if index >= notes.count / 2 {
                        if notes.count > 3 {
                            if backtracking {
                                if index == (notes.count/2) + 1 && notes.count > 4 {
                                    currentXModify -= 25
                                } else {
                                    currentXModify -= 50
                                }
                            } else {
                                if notes.count < 5 {
                                    currentXModify -= 25
                                }
                                backtracking = true
                            }
                        } else {
                            if backtracking {
                                currentXModify -= 25
                            } else {
                                backtracking = true
                            }
                        }
                    }
                    
                }
                
                if index > 0 && (Pitch.difference(from: note.pitch, to: notes[index-1].pitch) * -1) > 5 {
                    currentXModify = 0
                    backtracking = false
                }
                
                if let screenCoordinates = note.screenCoordinates, let accidental = note.accidental {
                    
                    var accidentalImageView:UIImageView?
                    
                    if accidental == .sharp, let image = UIImage(named: "sharp") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset - currentXModify, y: screenCoordinates.y + sharpAccidentalYOffset, width: 56/3, height: 150/3))
                        
                        accidentalImageView!.image = image
                    } else if accidental == .flat, let image = UIImage(named: "flat") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset - currentXModify, y: screenCoordinates.y + flatAccidentalYOffset, width: 56/3, height: 150/3))
                        
                        accidentalImageView!.image = image
                    } else if accidental == .natural, let image = UIImage(named: "natural") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset - currentXModify, y: screenCoordinates.y + naturalAccidentalYOffset, width: 56/4, height: 150/3))
                        
                        accidentalImageView!.image = image
                    } else if accidental == .doubleSharp, let accImage = UIImage(named: "double-sharp"), let noteHead = UIImage(named: "quarter-head") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset - 8 - currentXModify, y: screenCoordinates.y + doubleSharpAccidentalYOffset, width: noteHead.size.height/9.5, height: noteHead.size.height/9.5))
                        
                        accidentalImageView!.image = accImage
                    }
                    
                    if let accidentalImageView = accidentalImageView {
                        accidentalImageViews.append(accidentalImageView)
                    }
                    
                }
                
            }
            
            for accidentalImageView in accidentalImageViews {
                self.addSubview(accidentalImageView)
            }
        }
        
        func drawAccidentalsStaggered (notes: [Note]) {
            var currentStaggerMax: Int = 3
            var currentXModify: CGFloat = 0
            var accidentalImageViews = [UIImageView]()
            
            // also check if there is a difference between two notes that is > 5, this would restart the layout back nearest to the chord
            var staggerCount = 0
            for (index, note) in notes.enumerated() {
                if index != 0 {
                    currentXModify += 25
                    
                    if currentStaggerMax == staggerCount {
                        currentXModify = 0
                        currentStaggerMax += 1
                        staggerCount = 0
                    }
                }
                
                if let screenCoordinates = note.screenCoordinates, let accidental = note.accidental {
                    
                    var accidentalImageView:UIImageView?
                    
                    if accidental == .sharp, let image = UIImage(named: "sharp") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset - currentXModify, y: screenCoordinates.y + sharpAccidentalYOffset, width: 56/3, height: 150/3))
                        
                        accidentalImageView!.image = image
                    } else if accidental == .flat, let image = UIImage(named: "flat") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset - currentXModify, y: screenCoordinates.y + flatAccidentalYOffset, width: 56/3, height: 150/3))
                        
                        accidentalImageView!.image = image
                    } else if accidental == .natural, let image = UIImage(named: "natural") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset - currentXModify, y: screenCoordinates.y + naturalAccidentalYOffset, width: 56/4, height: 150/3))
                        
                        accidentalImageView!.image = image
                    } else if accidental == .doubleSharp, let accImage = UIImage(named: "double-sharp"), let noteHead = UIImage(named: "quarter-head") {
                        accidentalImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + accidentalXOffset - 8 - currentXModify, y: screenCoordinates.y + doubleSharpAccidentalYOffset, width: noteHead.size.height/9.5, height: noteHead.size.height/9.5))
                        
                        accidentalImageView!.image = accImage
                    }
                    
                    if let accidentalImageView = accidentalImageView {
                        accidentalImageViews.append(accidentalImageView)
                    }
                    
                }
                
                staggerCount += 1
                
            }
            
            for accidentalImageView in accidentalImageViews {
                self.addSubview(accidentalImageView)
            }
        }
        
        var largestDiffInPitch = 0
        var diffsInPitch = [Int]()
        var notesWithAccidental = [Note]()
        
        var topStackNote: Note?
        
        for note in chord.notes.reversed() {
            if let _ = note.accidental {
                topStackNote = note
                break
            }
        }
        
        for (index, note) in chord.notes.reversed().enumerated() {
            if note == topStackNote {
                notesWithAccidental.append(note)
                diffsInPitch.append(0)
                continue
            }
            
            if let _ = note.accidental, let topStackNote = topStackNote {
                notesWithAccidental.append(note)
                
                let currentDiff = Pitch.difference(from: topStackNote.pitch, to: note.pitch)
                diffsInPitch.append(currentDiff)
                
                if currentDiff > largestDiffInPitch {
                    largestDiffInPitch = currentDiff
                }
                
            }
        }
        
        /*if largestDiffInPitch > 1 { // zigzag
            
            drawAccidentalsZigzag(notes: notesWithAccidental)
            
        } else {
            
            if chord.notes.count < 4 { //  zigzag
                
                for note in notesWithAccidental {
                    
                }
                
            } else { // stagger
                
                var currentStaggerMax = 2
                
                for note in notesWithAccidental {
                    
                }
                
            }
            
        }*/
        
        if Chord.isSeventh(notes: notesWithAccidental) {
            drawAccidentalsStaggered(notes: notesWithAccidental)
        } else {
            drawAccidentalsZigzag(notes: notesWithAccidental)
        }
    }
    
    func drawDotsByNotation(notation: MusicNotation, highlighted: Bool = false, hasFlipped: Bool = false) { // 'hasFlipped' is for chords having flipped notes within it
        
        var dotImageView:UIImageView?
        var curSpacing: CGFloat = 45
        
        var pointToFollow: CGPoint?
        
        if let chord = notation as? Chord {
            var occupiedPoints = [CGPoint]()
            
            for note in chord.notes {
                
                curSpacing = 45
                
                if let measure = note.measure, let screenCoordinates = note.screenCoordinates, let measurePoints = GridSystem.instance.getPointsFromMeasure(measure: measure), let snapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: measurePoints) {
                    
                    var pitchToModify = Pitch(step: note.pitch.step, octave: note.pitch.octave)
                    pointToFollow = CGPoint(x: screenCoordinates.x, y: GridSystem.instance.getYFromPitch(pitch: pitchToModify, clef: measure.clef, snapPoints: snapPoints))
                    
                    if GridSystem.instance.isPitchInLine(pitch: note.pitch) {
                        
                        pitchToModify.transposeUp()
                        pointToFollow = CGPoint(x: screenCoordinates.x, y: GridSystem.instance.getYFromPitch(pitch: pitchToModify, clef: measure.clef, snapPoints: snapPoints))
                        
                        if occupiedPoints.contains(pointToFollow!) {
                            pitchToModify.transposeDown()
                            pitchToModify.transposeDown()
                            pointToFollow = CGPoint(x: screenCoordinates.x, y: GridSystem.instance.getYFromPitch(pitch: pitchToModify, clef: measure.clef, snapPoints: snapPoints))
                            
                            if occupiedPoints.contains(pointToFollow!) {
                                continue
                            }
                            
                            occupiedPoints.append(pointToFollow!)
                        } else {
                            occupiedPoints.append(pointToFollow!)
                        }
                    } else if occupiedPoints.contains(pointToFollow!){
                        pitchToModify.transposeDown()
                        pitchToModify.transposeDown()
                        pointToFollow = CGPoint(x: screenCoordinates.x, y: GridSystem.instance.getYFromPitch(pitch: pitchToModify, clef: measure.clef, snapPoints: snapPoints))
                        
                        if occupiedPoints.contains(pointToFollow!) {
                            continue
                        }
                        
                        occupiedPoints.append(pointToFollow!)
                    } else {
                        pointToFollow = screenCoordinates
                    }
                } else if let screenCoordinates = note.screenCoordinates {
                    pointToFollow = screenCoordinates
                }
                
                if let dotImage = UIImage(named: "dot"), let screenCoordinates = pointToFollow {
                    for _ in 0..<notation.dots {
                        if hasFlipped {
                            dotImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + curSpacing + 27, y: screenCoordinates.y - 3, width: dotImage.size.width/3, height: dotImage.size.height/3))
                        } else {
                            dotImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + curSpacing, y: screenCoordinates.y - 3, width: dotImage.size.width/3, height: dotImage.size.height/3))
                        }
                        dotImageView?.image = dotImage
                        
                        if highlighted {
                            dotImageView?.image = dotImageView?.image?.withRenderingMode(.alwaysTemplate)
                            dotImageView?.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                            dotImageView?.tag = HIGHLIGHTED_NOTES_TAG
                        }
                        
                        if let dotImageView = dotImageView {
                            self.addSubview(dotImageView)
                        }
                        
                        curSpacing += 12
                    }
                }
            }
        } else {
        
            if let note = notation as? Note, let measure = note.measure, let screenCoordinates = notation.screenCoordinates, let measurePoints = GridSystem.instance.getPointsFromMeasure(measure: measure), let snapPoints = GridSystem.instance.getSnapPointsFromPoints(measurePoints: measurePoints) {
                if GridSystem.instance.isPitchInLine(pitch: note.pitch) {
                    var upperPitch = Pitch(step: note.pitch.step, octave: note.pitch.octave)
                    upperPitch.transposeUp()
                    pointToFollow = CGPoint(x: screenCoordinates.x, y: GridSystem.instance.getYFromPitch(pitch: upperPitch, clef: measure.clef, snapPoints: snapPoints))
                } else {
                    pointToFollow = screenCoordinates
                }
            } else if let screenCoordinates = notation.screenCoordinates {
                pointToFollow = screenCoordinates
            }
            
            if let dotImage = UIImage(named: "dot"), let screenCoordinates = pointToFollow {
                for _ in 0..<notation.dots {
                    if notation is Rest {
                        if notation.type == .whole {
                            dotImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + curSpacing - 5, y: screenCoordinates.y + wholeRestYOffset, width: dotImage.size.width/3, height: dotImage.size.height/3))
                        } else if notation.type == .half {
                            dotImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + curSpacing - 5, y: screenCoordinates.y + halfRestYOffset, width: dotImage.size.width/3, height: dotImage.size.height/3))
                        } else {
                            dotImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + curSpacing - 10, y: screenCoordinates.y + 10, width: dotImage.size.width/3, height: dotImage.size.height/3))
                        }
                    } else if notation is Note {
                        if hasFlipped {
                            dotImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + curSpacing + 27, y: screenCoordinates.y - 3, width: dotImage.size.width/3, height: dotImage.size.height/3))
                        } else {
                            dotImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + curSpacing, y: screenCoordinates.y - 3, width: dotImage.size.width/3, height: dotImage.size.height/3))
                        }
                    }
                    dotImageView?.image = dotImage
                    
                    if highlighted {
                        dotImageView?.image = dotImageView?.image?.withRenderingMode(.alwaysTemplate)
                        dotImageView?.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
                        dotImageView?.tag = HIGHLIGHTED_NOTES_TAG
                    }
                    
                    if let dotImageView = dotImageView {
                        self.addSubview(dotImageView)
                    }
                    
                    curSpacing += 12
                }
            }
            
        }
        
    }

    func transposeUp() {
        if !self.selectedNotations.isEmpty {
            self.transpose(direction: .up)
            self.transformView.isHidden = false
            self.addSubview(self.transformView)

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
            self.transformView.isHidden = false
            self.addSubview(self.transformView)

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
    
    private func redirectCursorOnAction(params: Parameters) {
        
        DispatchQueue.global(qos: .background).async {
            while(self.executeLock) {
                // prevent from moving before lock
            }
            
            DispatchQueue.main.async {
                if let action = params.get(key: KeyNames.ACTION_DONE) as? Action {
                    
                    let type = params.get(key: KeyNames.ACTION_TYPE, defaultValue: "")
                    if type.isEmpty {
                        return
                    }
                    
                    var nextPoint: CGPoint?
                    
                    if let addAction = action as? AddAction {
                        
                        switch type {
                        case ActionFunctions.EXECUTE :
                            var currentPoint: CGPoint = self.sheetCursor.curYCursorLocation
                            if let note = addAction.notations[addAction.notations.count-1] as? Note {
                                currentPoint = note.screenCoordinates!
                            } else if let chord = addAction.notations[addAction.notations.count-1] as? Chord {
                                currentPoint = chord.notes[0].screenCoordinates!
                            }
                            
                            if let point = GridSystem.instance.getRightXSnapPoint(currentPoint: currentPoint) {
                                if let rightPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: point) {
                                    if addAction.notations[addAction.notations.count-1] is Rest {
                                        if let righterPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: rightPoint) {
                                            nextPoint = righterPoint
                                        }
                                    } else {
                                        nextPoint = rightPoint
                                    }
                                }
                            } else {
                                return
                            }
                        case ActionFunctions.REDO :
                            var currentPoint: CGPoint = self.sheetCursor.curYCursorLocation
                            if let note = addAction.notations[addAction.notations.count-1] as? Note {
                                currentPoint = note.screenCoordinates!
                            } else if let chord = addAction.notations[addAction.notations.count-1] as? Chord {
                                currentPoint = chord.notes[0].screenCoordinates!
                            }
                            
                            if let point = GridSystem.instance.getRightXSnapPoint(currentPoint: currentPoint) {
                                if let rightPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: point) {
                                    if addAction.notations[addAction.notations.count-1] is Rest {
                                        if let righterPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: rightPoint) {
                                            nextPoint = righterPoint
                                        }
                                    } else {
                                        nextPoint = rightPoint
                                    }
                                }
                            } else {
                                return
                            }
                        case ActionFunctions.UNDO :
                            var currentPoint: CGPoint = addAction.notations[addAction.notations.count-1].screenCoordinates!
                            
                            if let chord = addAction.notations[addAction.notations.count-1] as? Chord {
                                currentPoint = chord.notes[0].screenCoordinates!
                            }
                            
                            if let leftPoint = GridSystem.instance.getLeftXSnapPoint(currentPoint: currentPoint) {
                                nextPoint = leftPoint
                            } else {
                                return
                            }
                        default:
                            return
                        }
                        
                        
                    } else if let editAction = action as? EditAction {
                        
                        switch type {
                        case ActionFunctions.EXECUTE :
                            
                            if editAction.newNotations[editAction.newNotations.count - 1] is Chord {
                                self.moveCursorsToNearestSnapPoint(location: self.sheetCursor.curYCursorLocation)
                            } else {
                                var currentPoint: CGPoint = self.sheetCursor.curYCursorLocation
                                if let note = editAction.newNotations[editAction.newNotations.count - 1] as? Note {
                                    if let coordinates = note.screenCoordinates {
                                        currentPoint = coordinates
                                    }
                                }
                                
                                if let point = GridSystem.instance.getRightXSnapPoint(currentPoint: currentPoint) {
                                    if let rightPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: point) {
                                        if editAction.newNotations[editAction.newNotations.count - 1] is Rest {
                                            if let righterPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: rightPoint) {
                                                nextPoint = righterPoint
                                            }
                                        } else {
                                            nextPoint = rightPoint
                                        }
                                    }
                                } else {
                                    return
                                }
                            }
                            
                        case ActionFunctions.REDO :
                            
                            if editAction.newNotations[editAction.newNotations.count - 1] is Chord {
                                self.moveCursorsToNearestSnapPoint(location: self.sheetCursor.curYCursorLocation)
                            } else {
                                var currentPoint: CGPoint = self.sheetCursor.curYCursorLocation
                                if let note = editAction.newNotations[editAction.newNotations.count - 1] as? Note {
                                    if let coordinates = note.screenCoordinates {
                                        currentPoint = coordinates
                                    }
                                }
                                
                                if let point = GridSystem.instance.getRightXSnapPoint(currentPoint: currentPoint) {
                                    if let rightPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: point) {
                                        if editAction.newNotations[editAction.newNotations.count - 1] is Rest {
                                            if let righterPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: rightPoint) {
                                                nextPoint = righterPoint
                                            }
                                        } else {
                                            nextPoint = rightPoint
                                        }
                                    }
                                } else {
                                    return
                                }
                            }
                            
                        case ActionFunctions.UNDO :
                            
                            if editAction.oldNotations[editAction.oldNotations.count - 1] is Chord {
                                self.moveCursorsToNearestSnapPoint(location: self.sheetCursor.curYCursorLocation)
                            } else {
                                self.remapCurrentMeasure(location: editAction.oldNotations[editAction.oldNotations.count - 1].screenCoordinates!)
                                self.moveCursorsToNearestSnapPoint(location: editAction.oldNotations[editAction.oldNotations.count - 1].screenCoordinates!)
                            }
                            
                        default:
                            return
                        }
                        
                    } else if let deleteAction = action as? DeleteAction {
                        
                        switch type {
                        case ActionFunctions.EXECUTE :
                            
                            if let chord = deleteAction.notations[0] as? Chord {
                                self.remapCurrentMeasure(location: chord.notes[0].screenCoordinates!)
                                self.moveCursorsToNearestSnapPoint(location: chord.notes[0].screenCoordinates!)
                            } else {
                                self.remapCurrentMeasure(location: deleteAction.notations[0].screenCoordinates!)
                                self.moveCursorsToNearestSnapPoint(location: deleteAction.notations[0].screenCoordinates!)
                            }
                            
                        case ActionFunctions.REDO :
                            
                            if let chord = deleteAction.notations[0] as? Chord {
                                self.remapCurrentMeasure(location: chord.notes[0].screenCoordinates!)
                                self.moveCursorsToNearestSnapPoint(location: chord.notes[0].screenCoordinates!)
                            } else {
                                self.remapCurrentMeasure(location: deleteAction.notations[0].screenCoordinates!)
                                self.moveCursorsToNearestSnapPoint(location: deleteAction.notations[0].screenCoordinates!)
                            }
                            
                        case ActionFunctions.UNDO :
                            
                            var currentPoint: CGPoint = self.sheetCursor.curYCursorLocation
                            if let note = deleteAction.notations[deleteAction.notations.count-1] as? Note {
                                currentPoint = note.screenCoordinates!
                            } else if let chord = deleteAction.notations[deleteAction.notations.count-1] as? Chord {
                                currentPoint = chord.notes[0].screenCoordinates!
                            }
                            
                            if let point = GridSystem.instance.getRightXSnapPoint(currentPoint: currentPoint) {
                                if let rightPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: point) {
                                    if deleteAction.notations[deleteAction.notations.count-1] is Rest {
                                        if let righterPoint = GridSystem.instance.getRightXSnapPoint(currentPoint: rightPoint) {
                                            nextPoint = righterPoint
                                        }
                                    } else {
                                        nextPoint = rightPoint
                                    }
                                }
                            } else {
                                return
                            }
                            
                        default:
                            return
                        }
                        
                    }
                    
                    if let nextPoint = nextPoint {
                        self.remapCurrentMeasure(location: nextPoint)
                        self.sheetCursor.curXCursorLocation.x = nextPoint.x
                        
                        self.moveCursorX(location: self.sheetCursor.curXCursorLocation)
                        self.moveCursorY(location: nextPoint)
                    }
                }
            }
        }
    }
    
    public func moveCursorY(location: CGPoint) {
        
        if sheetCursor.isLocked {
            return
        }
        
        GridSystem.instance.selectedCoord = location
        sheetCursor.moveCursorY(location: location)

        if let measurePoints = GridSystem.instance.selectedMeasureCoord {
            sheetCursor.showLedgerLinesGuide(measurePoints: measurePoints, upToLocation: location, lineSpace: lineSpace)
            
            scrollMusicSheetToYIfPointNotVisible(y: measurePoints.lowerRightPoint.y - 140, targetPoint: sheetCursor.curYCursorLocation)
            scrollMusicSheetToXIfPointNotVisible(x: measurePoints.upperLeftPoint.x - 140, targetPoint: sheetCursor.curYCursorLocation)
        }
        
        DispatchQueue.global(qos: .background).async {
            while(self.executeLock) {
                // prevent from moving before lock
            }
            
            DispatchQueue.main.async {
                
                if let notation = GridSystem.instance.getNotationFromSnapPoint(snapPoint: location) {
                    self.hoveredNotation = notation
                } else {
                    self.hoveredNotation = nil
                    
                    if let noteFromX = GridSystem.instance.getNoteFromX(x: location.x) {
                        if let measure = GridSystem.instance.getCurrentMeasure() {
                            measure.updateInvalidNotes(invalidNotes: measure.getInvalidNotes(without: noteFromX))
                        }
                        
                        if let note = noteFromX as? Note, note.chord == nil {
                            self.highlightNotation(noteFromX, true)
                        } else if noteFromX is Rest {
                            self.highlightNotation(noteFromX, true)
                        }
                    } else {
                        if let measure = GridSystem.instance.getCurrentMeasure() {
                            measure.updateInvalidNotes(invalidNotes: measure.getInvalidNotes(numDots: self.getCurrentDotMode()))
                        }
                    }
                }
                
            }
        }
        
    }

    private func drawLedgerLinesIfApplicable (measurePoints: GridSystem.MeasurePoints,upToLocation: CGPoint) {

        if upToLocation.y < measurePoints.lowerRightPoint.y {

            var currentPoint = CGPoint(x:upToLocation.x, y: measurePoints.lowerRightPoint.y - lineSpace)

            while currentPoint.y >= upToLocation.y-1.5 {
                let _ = drawLine(start: CGPoint(x: upToLocation.x, y: currentPoint.y),
                                 end: CGPoint(x: upToLocation.x + 45, y: currentPoint.y), thickness: 2)

                currentPoint = CGPoint(x:currentPoint.x, y: currentPoint.y - lineSpace)
            }

        } else if upToLocation.y > measurePoints.upperLeftPoint.y {

            var currentPoint = CGPoint(x:upToLocation.x, y: measurePoints.upperLeftPoint.y + lineSpace)

            while currentPoint.y <= upToLocation.y {
                let _ = drawLine(start: CGPoint(x: upToLocation.x, y: currentPoint.y),
                                 end: CGPoint(x: upToLocation.x + 45, y: currentPoint.y), thickness: 2)

                currentPoint = CGPoint(x:currentPoint.x, y: currentPoint.y + lineSpace)
            }

        }

    }

    public func moveCursorX(location: CGPoint) {
        if !sheetCursor.isLocked {
            sheetCursor.moveCursorX(location: location)
        }
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

                if let note = notation as? Note {

                    if let connection = note.connection, let cNotes = connection.notes, let index = cNotes.index(of: note) {
                        var newNote = note.duplicate()

                        if let newConnection = newNote.connection, let newCNotes = newConnection.notes {
                            for newCNote in newCNotes {
                                if let connection = newCNote.connection {
                                    connection.notes![index] = newNote
                                }
                            }

                            newNotations.append(newNote)
                        }

                    } else {
                        newNotations.append(notation.duplicate())
                    }

                    note.pitch = self.initialPitches.removeFirst()
                } else {
                    newNotations.append(notation.duplicate())
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

            var newNoteConnections = [Note]()

            self.updateMeasureDraw()

            // UPDATE CONNECTIONS OF TRANSPOSED NOTES
            /*if allNotes(notations: newNotations) {
                var newNotes = [Note]()

                for note in newNotations {
                    if let note = note as? Note {
                        newNotes.append(note)
                    }
                }

                for note in newNotes {
                    if let connection = note.connection {
                        if connection.notes.count != newNotes.count{

                        } else {
                            connection.notes = newNotes
                        }
                    }
                }
            }*/
            
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

        executeLock = true
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
            
            sheetCursor.hideCursors()

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
            
            if let chord = note.chord {
                
                var flipped = false
                
                image = chord.image
                
                for (index, note) in chord.notes.enumerated() {
                    
                    if let screenCoordinates = note.screenCoordinates, let image = note.image {
                        
                        if index > 0 {
                            if Pitch.difference(from: note.pitch, to: chord.notes[index-1].pitch) == 1 && !flipped {
                                if notation == note {
                                    notationImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset + 24, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter))
                                }
                                
                                flipped = true
                            } else {
                                if notation == note {
                                    notationImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter))
                                }
                                
                                flipped = false
                            }
                        } else {
                            if notation == note {
                                notationImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter))
                            }
                            
                            flipped = false
                        }
                        
                        //drawAccidentalByNote(note: note)
                        //drawDotsByNotation(notation: note)
                        
                        if let measure = chord.measure {
                            if let measurePoints = GridSystem.instance.getPointsFromMeasure(measure: measure) {
                                drawLedgerLinesIfApplicable(measurePoints: measurePoints, upToLocation: screenCoordinates)
                            }
                        }
                    }
                    
                }
                
            } else {
            
                if let screenCoordinates = note.screenCoordinates {

                    image = note.image

                    if note.type.getBeatValue() <= RestNoteType.eighth.getBeatValue() && note.beamed {
                        image = UIImage(named: "quarter-head")
                    }

                    if let image = image {
                        notationImageView = UIImageView(frame: CGRect(x: screenCoordinates.x + noteXOffset, y: screenCoordinates.y + noteYOffset, width: image.size.width + noteWidthAlter, height: image.size.height + noteHeightAlter))
                        drawAccidentalByNote(note: note, highlighted: true)
                        drawDotsByNotation(notation: note, highlighted: true)
                    }
                    
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
                    
                    drawDotsByNotation(notation: rest, highlighted: true)
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
                if note.measure == measure {
                    totalBeats = totalBeats + note.type.getBeatValue()
                    print(note.type.getBeatValue())
                }
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
                                        
                                        //scrollMusicSheetToYIfPointNotVisible(y: newMeasurePoints.lowerRightPoint.y - 140, targetPoint: sheetCursor.curYCursorLocation)
                                        //scrollMusicSheetToXIfPointNotVisible(x: newMeasurePoints.upperLeftPoint.x - 140, targetPoint: sheetCursor.curYCursorLocation)

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
                                        
                                        //scrollMusicSheetToYIfPointNotVisible(y: newMeasurePoints.lowerRightPoint.y - 140, targetPoint: sheetCursor.curYCursorLocation)
                                        //scrollMusicSheetToXIfPointNotVisible(x: newMeasurePoints.upperLeftPoint.x - 140, targetPoint: sheetCursor.curYCursorLocation)

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
        
        drawDotsByNotation(notation: notation)
        
        if let note = notation as? Note {
            drawAccidentalByNote(note: note)
            
            if let measure = note.measure, let screenCoordinates = note.screenCoordinates {
                if let measurePoints = GridSystem.instance.getPointsFromMeasure(measure: measure) {
                    drawLedgerLinesIfApplicable(measurePoints: measurePoints, upToLocation: screenCoordinates)
                }
            }
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
            
            sheetCursor.hideCursors()
            
            for view in self.subviews {
                if view.tag == HIGHLIGHTED_NOTES_TAG {
                    view.isHidden = true
                }
            }
            
            if let composition = self.composition {
                SoundManager.instance.musicPlayback(composition)

                if #available(iOS 10.0, *) {
                    playBackTimer = Timer.scheduledTimer(withTimeInterval: 60 / SoundManager.instance.tempo * 0.0078125, repeats: true) { _ in
                        self.updateTime()
                    }
                } else {
                    playBackTimer = Timer.scheduledTimer(timeInterval: 60 / SoundManager.instance.tempo * 0.0078125,
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
        
        for view in self.subviews {
            if view.tag == HIGHLIGHTED_NOTES_TAG {
                view.isHidden = false
            }
        }
        
        sheetCursor.showCursors()
        
        self.playbackHighlightRect.path = nil
    }

    @objc
    func updateTime() {
        //TODO: IMPLEMENT PLAYBACK FRONTEND

        /*let xIterate: CGFloat = CGFloat(SoundManager.instance.tempo / 10)

        sheetCursor.moveCursorX(location: CGPoint(x: sheetCursor.curXCursorLocation.x + xIterate, y: sheetCursor.curXCursorLocation.y))*/

    }

    private func highlightParallelMeasures(parameters: Parameters) {
        if let currentPlayingMeasure:Measure = parameters.get(key: KeyNames.HIGHLIGHT_MEASURE) as? Measure {

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

    public func highlightSelected() {
        for notation in self.selectedNotations {
            highlightNotation(notation, false)
        }
    }

    public func titleChanged(params: Parameters) {
        print("here")
        if let composition = self.composition {
            composition.compositionInfo.name = params.get(key: KeyNames.NEW_TITLE, defaultValue: "Untitled Composition")
        }
    }

    public func accidentalPress(params: Parameters) {
        var newNotes = [MusicNotation]()

        let accidental = params.get(key: KeyNames.ACCIDENTAL) as! Accidental

        if !self.selectedNotations.isEmpty {
            var oldNotes = [MusicNotation]()

            if !sameAccidentals(notations: self.selectedNotations, accidental: accidental) {

                var alreadyEdited = [Int]()

                for (index, note) in self.selectedNotations.enumerated() {
                    if alreadyEdited.contains(index) {
                        continue
                    }

                    if let note = note as? Note {

                        if let chord = note.chord{

                            var newNotesInChord = [Note]()
                            var indicesToBeEdited = [Int]()

                            for notation in selectedNotations {
                                if let otherNote = notation as? Note, let otherChord = otherNote.chord, let noteIndex = otherChord.notes.index(of: otherNote), let selectedIndex = selectedNotations.index(of: otherNote) {
                                    if chord == otherChord {
                                        let newNote = otherNote.duplicate()
                                        newNote.accidental = accidental

                                        newNotesInChord.append(newNote)
                                        alreadyEdited.append(selectedIndex)
                                        indicesToBeEdited.append(noteIndex)
                                    }
                                }
                            }

                            let newChord = chord.duplicate()

                            for (index, newNote) in newNotesInChord.enumerated() {
                                newChord.notes[indicesToBeEdited[index]] = newNote
                                newNote.chord = newChord
                            }

                            oldNotes.append(chord)
                            newNotes.append(newChord)

                        } else {

                            let newNote = note.duplicate()
                            newNote.accidental = accidental

                            //self.selectedNotations[index] = newNote

                            oldNotes.append(note)
                            newNotes.append(newNote)

                        }

                    } else if let chord = note as? Chord { // for the whole chord

                        var newNotesInChord = [Note]()
                        var indicesToBeEdited = [Int]()

                        for note in chord.notes {
                            if let noteIndex = chord.notes.index(of: note) {
                                let newNote = note.duplicate()
                                newNote.accidental = accidental

                                newNotesInChord.append(newNote)
                                indicesToBeEdited.append(noteIndex)
                            }
                        }

                        let newChord = chord.duplicate()

                        for (index, newNote) in newNotesInChord.enumerated() {
                            newChord.notes[indicesToBeEdited[index]] = newNote
                            newNote.chord = newChord
                        }

                        oldNotes.append(chord)
                        newNotes.append(newChord)

                    }
                }
            } else {
                
                var alreadyEdited = [Int]()
                
                for (index, note) in self.selectedNotations.enumerated() { // for removing accidentals
                    if alreadyEdited.contains(index) {
                        continue
                    }
                    
                    if let note = note as? Note {
                        
                        if let chord = note.chord {
                            
                            var newNotesInChord = [Note]()
                            var indicesToBeEdited = [Int]()
                            
                            for notation in selectedNotations {
                                if let otherNote = notation as? Note, let otherChord = otherNote.chord, let noteIndex = otherChord.notes.index(of: otherNote), let selectedIndex = selectedNotations.index(of: otherNote) {
                                    if chord == otherChord {
                                        let newNote = otherNote.duplicate()
                                        newNote.accidental = nil
                                        
                                        newNotesInChord.append(newNote)
                                        alreadyEdited.append(selectedIndex)
                                        indicesToBeEdited.append(noteIndex)
                                    }
                                }
                            }
                            
                            let newChord = chord.duplicate()
                            
                            for (index, newNote) in newNotesInChord.enumerated() {
                                newChord.notes[indicesToBeEdited[index]] = newNote
                                newNote.chord = newChord
                            }
                            
                            oldNotes.append(chord)
                            newNotes.append(newChord)
                        } else {
                            
                            let newNote = note.duplicate()
                            newNote.accidental = nil
                            
                            oldNotes.append(note)
                            newNotes.append(newNote)
                            
                        }
                        
                    } else if let chord = note as? Chord {
                        
                        var newNotesInChord = [Note]()
                        var indicesToBeEdited = [Int]()
                        
                        for note in chord.notes {
                            if let noteIndex = chord.notes.index(of: note) {
                                let newNote = note.duplicate()
                                newNote.accidental = nil
                                
                                newNotesInChord.append(newNote)
                                indicesToBeEdited.append(noteIndex)
                            }
                        }
                        
                        let newChord = chord.duplicate()
                        
                        for (index, newNote) in newNotesInChord.enumerated() {
                            newChord.notes[indicesToBeEdited[index]] = newNote
                            newNote.chord = newChord
                        }
                        
                        oldNotes.append(chord)
                        newNotes.append(newChord)
                        
                    }
                }
            }
            
            if newNotes.count > 0 {
                var new = [Note]()

                if allNotes(notations: newNotes) {
                    for notation in newNotes {
                        if let note = notation as? Note {
                            new.append(note)
                        }
                    }

                    for notation in newNotes {
                        if let note = notation as? Note, let connection = note.connection {
                            connection.notes = new
                        }
                    }
                }

                let editAction = EditAction(old: oldNotes, new: new)
                
                editAction.execute()
                
                selectedNotations = newNotes
                self.updateMeasureDraw()
            }
            
            self.transformView.isHidden = false
            self.addSubview(self.transformView)
        } else if let hovered = self.hoveredNotation {
            if let curNote = hovered as? Note {
                
                let newNote = curNote.duplicate()

                if curNote.accidental != accidental {
                    newNote.accidental = accidental
                } else {
                    newNote.accidental = nil
                }
                
                if let chord = curNote.chord, let index = chord.notes.index(of: curNote) {
                    
                    let newChord = chord.duplicate()
                    newChord.notes[index] = newNote
                    newNote.chord = newChord
                    
                    newNotes.append(newChord)
                    
                    if newNotes.count > 0 {
                        let editAction = EditAction(old: [chord], new: newNotes)
                        
                        editAction.execute()
                        
                        self.updateMeasureDraw()
                    }
                    
                } else {

                    newNotes.append(newNote)
                    
                    if newNotes.count > 0 {
                        let editAction = EditAction(old: [hovered], new: newNotes)
                        
                        editAction.execute()
                        
                        self.updateMeasureDraw()
                    }
                }
                
            }
        } else {
            if self.accidentalMode == accidental {
                self.accidentalMode = nil
            } else {
                self.accidentalMode = accidental
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
            } else if let chord = notation as? Chord {
                
                if sameAccidentals(notations: chord.notes, accidental: accidental) {
                    accidentalCount += 1
                }
                
            } else {
                return false
            }
        }

        return accidentalCount == notations.count
    }

    public func sameOttava(notations: [MusicNotation]) -> Bool {
        var ottava: OttavaType? = nil

        for notation in notations {
            if let note = notation as? Note {
                if note.ottava != nil {
                    if ottava == nil {
                        ottava = note.ottava
                    } else {
                        if note.ottava != ottava {
                            return false
                        }
                    }
                } else {
                    return false
                }
            } else if let chord = notation as? Chord {
                if chord.ottava != nil {
                    if ottava == nil {
                        ottava = chord.ottava
                    } else {
                        if chord.ottava != ottava {
                            return false
                        }
                    }
                } else {
                    return false
                }
            }
        }

        return true
    }

    func allChords(notations: [MusicNotation]) -> Bool {
        for notation in notations {
            if notation is Rest || notation is Note {
                return false
            }
        }

        return true
    }

    func sameConnections(notations: [MusicNotation]) -> Bool {
        var connectionType: ConnectionType? = nil

        if notations.count > 1 {
            for notation in notations {
                if let note = notation as? Note {

                    if let noteConnection = note.connection {
                        if let type = noteConnection.type {
                            if connectionType == nil {
                                connectionType = type
                            } else {
                                if connectionType != type {
                                    return false
                                }
                            }
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }

                } else if let chord = notation as? Chord {

                    if let chordConnection = chord.connection {
                        if let type = chordConnection.type {
                            if connectionType == nil {
                                connectionType = type
                            } else {
                                if connectionType != type {
                                    return false
                                }
                            }
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }

                }
            }
        } else {
            return false
        }
        
        return true
    }

    func connection(params: Parameters) {
        var connection = params.get(key: KeyNames.CONNECTION) as! Connection

        if self.selectedNotations.count > 1 {

            if allNotes(notations: self.selectedNotations) {

                if sameConnections(notations: self.selectedNotations) {
                    // remove all ties
                } else {
                    var connectedNotes = [Note]()
                    var newNotes = [Note]()

                    for notation in self.selectedNotations {
                        if let note = notation as? Note {
                            connectedNotes.append(note)
                        }
                    }

                    connection.notes = connectedNotes

                    for note in connectedNotes {
                        var newNote = note.duplicate()
                        newNote.connection = connection
                        newNotes.append(newNote)
                    }

                    let editAction = EditAction(old: connectedNotes, new: newNotes)
                    editAction.execute()

                    for note in newNotes {
                        if let connection = note.connection {
                            connection.notes = newNotes
                        }
                    }

                    selectedNotations.removeAll()
                    selectedNotations = newNotes

                    self.updateMeasureDraw()
                    repositionTransformView(first: false)
                }

            } else if allChords(notations: self.selectedNotations) {

            }


        }
    }

    public func ottava(params: Parameters) {
        let ottavaType = params.get(key: KeyNames.OTTAVA) as! OttavaType

        var newNotations = [MusicNotation]()

        if !selectedNotations.isEmpty {
            for notation in selectedNotations {
                if let note = notation as? Note {
                    let newNote = note.duplicate()

                    if note.ottava != ottavaType {
                        newNote.ottava = ottavaType
                    } else if note.ottava == ottavaType && sameOttava(notations: self.selectedNotations) {
                        newNote.ottava = nil
                    }

                    newNotations.append(newNote)
                } else if let chord = notation as? Chord {
                    let newChord = chord.duplicate()

                    if chord.ottava != ottavaType {
                        newChord.ottava = ottavaType
                    } else if chord.ottava == ottavaType && sameOttava(notations: self.selectedNotations) {
                        newChord.ottava = nil
                    }

                    newNotations.append(newChord)
                } else {
                    newNotations.append(notation.duplicate())
                }
            }

            if !newNotations.isEmpty {
                let editAction = EditAction(old: self.selectedNotations, new: newNotations)
                editAction.execute()
            }

            selectedNotations.removeAll()
            selectedNotations = newNotations

            self.updateMeasureDraw()
            repositionTransformView(first: false)
        } else if let notation = self.hoveredNotation {
            if let note = notation as? Note {
                let newNote = note.duplicate()

                if note.ottava != ottavaType {
                    newNote.ottava = ottavaType
                } else if note.ottava == ottavaType {
                    newNote.ottava = nil
                }

                newNotations.append(newNote)
            } else if let chord = notation as? Chord {
                let newChord = chord.duplicate()

                if chord.ottava != ottavaType {
                    newChord.ottava = ottavaType
                } else if chord.ottava == ottavaType {
                    newChord.ottava = nil
                }

                newNotations.append(newChord)
            } else {
                newNotations.append(notation.duplicate())
            }

            if !newNotations.isEmpty {
                if let hovered = self.hoveredNotation {
                    if hovered is Note {
                        let editAction = EditAction(old: [hovered], new: newNotations)
                        editAction.execute()
                        self.updateMeasureDraw()
                    } else if hovered is Chord {
                        let editAction = EditAction(old: [hovered], new: newNotations)
                        editAction.execute()
                        self.updateMeasureDraw()
                    }
                }
            }
        } else {
            if self.ottavaMode == ottavaType {
                self.ottavaMode = nil
            } else {
                self.ottavaMode = ottavaType
            }
            
        }
    }

    func dotNotation(params: Parameters) {
        let numDots = params.get(key: KeyNames.NUM_OF_DOTS, defaultValue: 0)
        var addedValue: Float = 0

        var allDotsAreEqualToNumDots = true

        if numDots > 0 {

            if !selectedNotations.isEmpty {

                for notation in selectedNotations {
                    if notation.dots != numDots {
                        allDotsAreEqualToNumDots = false
                    }
                }

                if allDotsAreEqualToNumDots { // for removing dots

                    var oldNotations = [MusicNotation]()
                    var removedDottedNotes = [MusicNotation]()
                    var alreadyCheckedIndices = [Int]()

                    for (index, notation) in selectedNotations.enumerated() {

                        if alreadyCheckedIndices.contains(index) {
                            continue
                        }

                        if let note = notation as? Note, let chord = note.chord {

                            let newChord = chord.duplicate()

                            for note in chord.notes{
                                if let selectedIndex = selectedNotations.index(of: note) {
                                    alreadyCheckedIndices.append(selectedIndex)
                                }
                            }

                            newChord.dots = 0

                            oldNotations.append(chord)
                            removedDottedNotes.append(newChord)

                        } else {
                            let dottedNote = notation.duplicate()
                            dottedNote.dots = 0

                            oldNotations.append(notation)
                            removedDottedNotes.append(dottedNote)
                        }

                    }

                    if !removedDottedNotes.isEmpty {
                        let editAction = EditAction(old: oldNotations, new: removedDottedNotes)
                        editAction.execute()
                    }

                } else { // adding dots
                    var dottedNotations = [MusicNotation]()
                    var oldNotations = [MusicNotation]()

                    var alreadyCheckedIndices = [Int]()

                    for (index, notation) in selectedNotations.enumerated() {

                        if alreadyCheckedIndices.contains(index) {
                            continue
                        }

                        if let measure = notation.measure {

                            let value = notation.type.getBeatValue(dots: numDots) - notation.type.getBeatValue(dots: notation.dots)

                            if measure.isAddNoteValid(addedValue: addedValue, value: value) {

                                if let note = notation as? Note, let chord = note.chord {

                                    let newChord = chord.duplicate()

                                    for note in chord.notes{
                                        if let selectedIndex = selectedNotations.index(of: note) {
                                            alreadyCheckedIndices.append(selectedIndex)
                                        }
                                    }

                                    newChord.dots = numDots

                                    oldNotations.append(chord)
                                    dottedNotations.append(newChord)

                                    addedValue += value

                                } else {

                                    let dottedNote = notation.duplicate()
                                    dottedNote.dots = numDots

                                    addedValue += value

                                    oldNotations.append(notation)
                                    dottedNotations.append(dottedNote)

                                }
                            } else {
                                dottedNotations.append(notation)
                            }
                        }
                    }

                    if !dottedNotations.isEmpty {
                        let editAction = EditAction(old: oldNotations, new: dottedNotations)
                        editAction.execute()
                    }
                }

            } else if let hovered = self.hoveredNotation ?? GridSystem.instance.getNoteFromX(x: sheetCursor.curYCursorLocation.x) {

                if hovered.dots == numDots {

                    if let note = hovered as? Note, let chord = note.chord {

                        let removedDottedChord = chord.duplicate()
                        removedDottedChord.dots = 0

                        let editAction = EditAction(old: [chord], new: [removedDottedChord])
                        editAction.execute()
                    } else {

                        let removedDottedNote = hovered.duplicate()
                        removedDottedNote.dots = 0

                        let editAction = EditAction(old: [hovered], new: [removedDottedNote])
                        editAction.execute()
                    }

                } else {

                    if let measure = hovered.measure {

                        let value = hovered.type.getBeatValue(dots: numDots) - hovered.type.getBeatValue(dots:hovered.dots)

                        if measure.isAddNoteValid(value: value) {

                            if let note = hovered as? Note, let chord = note.chord {
                                let dottedChord = chord.duplicate()
                                dottedChord.dots = numDots

                                let editAction = EditAction(old: [chord], new: [dottedChord])
                                editAction.execute()
                            } else {
                                let dottedNote = hovered.duplicate()
                                dottedNote.dots = numDots

                                let editAction = EditAction(old: [hovered], new: [dottedNote])
                                editAction.execute()
                            }

                        }
                    }

                }
            } else {
                switch numDots {
                case 1:
                    if dotModes[0] {
                        dotModes[0] = false
                    } else {
                        dotModes = [true, false, false]
                    }
                case 2:
                    if dotModes[1] {
                        dotModes[1] = false
                    } else {
                        dotModes = [false, true, false]
                    }
                case 3:
                    if dotModes[2] {
                        dotModes[2] = false
                    } else {
                        dotModes = [false, false, true]
                    }
                default:
                    dotModes = [false, false, false]
                }
            }

            selectedNotations.removeAll()
            self.updateMeasureDraw()
        }
    }

    func retrograde(notations: [MusicNotation]) {
        var retrograde = [MusicNotation]()

        for arrayIndex in stride(from: notations.count - 1, through: 0, by: -1) {
            retrograde.append(notations[arrayIndex].duplicate())
        }

        var newNotes = [Note]()

        if allNotes(notations: retrograde) {
            for notation in retrograde {
                if let note = notation as? Note {
                    newNotes.append(note)
                }
            }

            for notation in retrograde {
                if let note = notation as? Note, let connection = note.connection {
                    connection.notes = newNotes
                }
            }
        }

        let editAction = EditAction(old: notations, new: retrograde)

        editAction.execute()

        selectedNotations.removeAll()

        selectedNotations = retrograde

        self.updateMeasureDraw()

        repositionTransformView(first: true)
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

        var newNotes = [Note]()

        if allNotes(notations: invertedNotes) {
            for notation in invertedNotes {
                if let note = notation as? Note {
                    newNotes.append(note)
                }
            }

            for notation in invertedNotes {
                if let note = notation as? Note, let connection = note.connection {
                    connection.notes = newNotes

                    if let fNote = notations.first as? Note {
                        connection.notes!.insert(fNote, at: 0)
                    }
                }
            }
        }
        
        let editAction = EditAction(old: oldNotes, new: newNotes)
        
        editAction.execute()

        self.selectedNotations.removeAll()

        if let fNote = notations.first as? Note {
            newNotes.insert(fNote, at: 0)
        }

        self.selectedNotations = newNotes

        self.updateMeasureDraw()

        repositionTransformView(first: false)
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
    
    public func getCurrentDotMode() -> Int {
        for (index, dotMode) in dotModes.enumerated() {
            if dotMode {
                return index+1
            }
        }
        
        return 0
    }

    public func getCurrentAccidentalMode() -> Accidental? {
        if let accidentalMode = self.accidentalMode {
            return self.accidentalMode
        }

        return nil
    }

    public func getCurrentOttavaMode() -> OttavaType? {
        if let ottavaMode = self.ottavaMode {
            return self.ottavaMode
        }

        return nil
    }

    @IBAction func transposeUp(_ sender: UIButton) {
        self.transposeUp()
    }
    
    @IBAction func transposeDown(_ sender: UIButton) {
        self.transposeDown()
    }
    
    @IBAction func retrograde(_ sender: UIButton) {
        if selectedNotations.count > 1 {
            self.retrograde(notations: self.selectedNotations)
        }
    }
    
    @IBAction func inverse(_ sender: UIButton) {
        if selectedNotations.count > 1 {
            self.inverse(notations: self.selectedNotations)
        }
    }
    
}
