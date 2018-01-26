//
//  GridSystem.swift
//  Flow
//
//  Created by Patrick Tobias on 20/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation
import UIKit

class GridSystem {
    
    static let instance = GridSystem()
    
    static let NUMBER_OF_SNAPPOINTS_PER_COLUMN = 8

    public var selectedMeasureCoord:MeasurePoints? {
        didSet {
            if (oldValue != selectedMeasureCoord) {
                
                if let measureCoord = selectedMeasureCoord {
                    if let newMeasure = getMeasureFromPoints(measurePoints: measureCoord) {
                        let params:Parameters = Parameters()
                        params.put(key: KeyNames.NEW_MEASURE, value: newMeasure)
                        
                        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_SWITCHED, params: params)
                    }
                }
                
                print ("Measure switched!")
            }
        }
    }
    public var selectedCoord:CGPoint?
    public var currentStaffIndex:Int? {
        didSet {
            if (oldValue != currentStaffIndex) {
                EventBroadcaster.instance.postEvent(event: EventNames.STAFF_SWITCHED)
                print ("Staff switched!")
            }
        }
    }

    private var measureMap = [MeasurePoints: Measure]()
    private var weightsMap = [MeasurePoints: [CGPoint]]()
    private var snapPointsMap = [MeasurePoints: [CGPoint]]()
    public var measurePointsInStaff = [[MeasurePoints]]() // array index reflects staff number

    private var YPitchMap = [CGFloat: Pitch]()
    private var gClefPitches = [Pitch]()
    private var fClefPitches = [Pitch]()
    
    private init() {
        //GridSystem.sharedInstance = self

        initClefPitches()
    }
    
    public func reset() {
        selectedMeasureCoord = nil
        selectedCoord = CGPoint(x: -1, y: -1)
        measurePointsInStaff.removeAll()
        measureMap.removeAll()
        weightsMap.removeAll()
        snapPointsMap.removeAll()
        YPitchMap.removeAll()
        
        print("Grid System reset!")
    }

    private func initClefPitches() {

        gClefPitches.append(Pitch(step: Step.F, octave: 5))
        gClefPitches.append(Pitch(step: Step.E, octave: 5))
        gClefPitches.append(Pitch(step: Step.D, octave: 5))
        gClefPitches.append(Pitch(step: Step.C, octave: 5))
        gClefPitches.append(Pitch(step: Step.B, octave: 4))
        gClefPitches.append(Pitch(step: Step.A, octave: 4))
        gClefPitches.append(Pitch(step: Step.G, octave: 4))
        gClefPitches.append(Pitch(step: Step.F, octave: 4))
        gClefPitches.append(Pitch(step: Step.E, octave: 4))

        fClefPitches.append(Pitch(step: Step.A, octave: 3))
        fClefPitches.append(Pitch(step: Step.G, octave: 3))
        fClefPitches.append(Pitch(step: Step.F, octave: 3))
        fClefPitches.append(Pitch(step: Step.E, octave: 3))
        fClefPitches.append(Pitch(step: Step.D, octave: 3))
        fClefPitches.append(Pitch(step: Step.C, octave: 3))
        fClefPitches.append(Pitch(step: Step.B, octave: 2))
        fClefPitches.append(Pitch(step: Step.A, octave: 2))
        fClefPitches.append(Pitch(step: Step.G, octave: 2))

    }
    
    public func getMeasureFromPoints(measurePoints:MeasurePoints) -> Measure? {
        return measureMap[measurePoints]
    }
    
    public func getWeightsFromPoints(measurePoints:MeasurePoints) -> [CGPoint]? {
        return weightsMap[measurePoints]
    }
    
    public func getSnapPointsFromPoints(measurePoints:MeasurePoints) -> [CGPoint]? {
        return snapPointsMap[measurePoints]
    }
    
    public func assignMeasureToPoints(measurePoints:MeasurePoints, measure:Measure) {
        measureMap[measurePoints] = measure
    }
    
    public func assignSnapPointsToPoints(measurePoints:MeasurePoints, snapPoint:[CGPoint]) {
        snapPointsMap[measurePoints] = snapPoint
    }

    public func createNewMeasurePointsArray() {
        measurePointsInStaff.append([MeasurePoints]())
    }

    public func appendMeasurePointToLatestArray(measurePoints: MeasurePoints) {
        if !measurePointsInStaff.isEmpty {
            measurePointsInStaff[measurePointsInStaff.count - 1].append(measurePoints)
        }
    }

    public func getStaffIndexFromMeasurePoint(measurePoints: MeasurePoints) -> Int {
        var index = 0

        for measurePointsArray in measurePointsInStaff {
            if measurePointsArray.contains(measurePoints) {
                return index
            }
            index += 1
        }

        return -1
    }

    public func getFirstMeasurePointFromStaff(measurePoints: MeasurePoints) -> MeasurePoints {

        if let index = currentStaffIndex {
            let array = measurePointsInStaff[index]
            return array[0]
        }

        return MeasurePoints(upperLeftPoint: CGPoint(x: -1, y: -1), lowerRightPoint: CGPoint(x: -1, y: -1))

    }

    public func addMoreSnapPointsToPoints(measurePoints:MeasurePoints, snapPoints:[CGPoint]) {
        if var snapPointsFromMap = snapPointsMap[measurePoints] {
            snapPointsFromMap.append(contentsOf: snapPoints)
            snapPointsMap[measurePoints] = snapPointsFromMap
        } else {
            assignSnapPointsToPoints(measurePoints: measurePoints, snapPoint: snapPoints)
        }
    }
    
    public func removeRelativeXSnapPoints(measurePoints:MeasurePoints, relativeX:CGFloat) {
        if let snapPointsFromMap = snapPointsMap[measurePoints] {
            
            var pointsRemoved = [CGPoint]()
            
            for snapPoint in snapPointsFromMap {
                if snapPoint.x == relativeX {
                    pointsRemoved.append(snapPoint)
                }
            }
            
            snapPointsMap[measurePoints] = snapPointsFromMap.filter( {!pointsRemoved.contains($0)} )
        
        }
    }
    public func assignWeightsToPoints(measurePoints:MeasurePoints, weights:[CGPoint]) {
        weightsMap[measurePoints] = weights
    }

    public func assignYtoPitch(y: CGFloat, pitch: Pitch) {
        YPitchMap[y] = pitch
    }

    public func getPitchFromY(y: CGFloat) -> Pitch {
        return YPitchMap[y]!
    }

    public func getRightXSnapPoint(currentPoint: CGPoint) -> CGPoint {
        if let measureCoord = selectedMeasureCoord {

            var nearestPoint:CGPoint = currentPoint
            var leastDistance:CGFloat?
            if let snapPoints = snapPointsMap[measureCoord] {

                for (index, snapPoint) in snapPoints.enumerated() {
                    
                    if (snapPoint.y == currentPoint.y && snapPoint != currentPoint && snapPoint.x > currentPoint.x) {
                        let x2: CGFloat = currentPoint.x - snapPoint.x
                        let y2: CGFloat = currentPoint.y - snapPoint.y
                        
                        print(index)
                        print(snapPoint)

                        let potDistance = (x2 * x2) + (y2 * y2)
                        print(potDistance)
                        
                        if let theDistance = leastDistance {
                            if (potDistance < theDistance) {
                                leastDistance = potDistance
                                nearestPoint = snapPoint
                            }
                        } else {
                            leastDistance = potDistance
                            nearestPoint = snapPoint
                        }

                    }
                    
                }

                return nearestPoint

            }
        }

        return CGPoint(x: -1, y: -1)
    }

    public func getLeftXSnapPoint(currentPoint: CGPoint) -> CGPoint {
        if let measureCoord = selectedMeasureCoord {
            
            var nearestPoint:CGPoint = currentPoint
            var leastDistance:CGFloat?
            if let snapPoints = snapPointsMap[measureCoord] {
                
                for (index, snapPoint) in snapPoints.enumerated() {
                    
                    if (snapPoint.y == currentPoint.y && snapPoint != currentPoint && snapPoint.x < currentPoint.x) {
                        let x2: CGFloat = currentPoint.x - snapPoint.x
                        let y2: CGFloat = currentPoint.y - snapPoint.y
                        
                        print(index)
                        print(snapPoint)
                        
                        let potDistance = (x2 * x2) + (y2 * y2)
                        print(potDistance)
                        
                        if let theDistance = leastDistance {
                            if (potDistance < theDistance) {
                                leastDistance = potDistance
                                nearestPoint = snapPoint
                            }
                        } else {
                            leastDistance = potDistance
                            nearestPoint = snapPoint
                        }
                        
                    }
                    
                }
                
                return nearestPoint
                
            }
        }
        
        return CGPoint(x: -1, y: -1)
    }

    public func getUpYSnapPoint(currentPoint: CGPoint) -> CGPoint {
        if let measureCoord = selectedMeasureCoord {
            
            var nearestPoint:CGPoint = currentPoint
            var leastDistance:CGFloat?
            if let snapPoints = snapPointsMap[measureCoord] {
                
                for (index, snapPoint) in snapPoints.enumerated() {
                    
                    if (snapPoint.y < currentPoint.y && snapPoint != currentPoint && snapPoint.x == currentPoint.x) {
                        let x2: CGFloat = currentPoint.x - snapPoint.x
                        let y2: CGFloat = currentPoint.y - snapPoint.y
                        
                        print(index)
                        print(snapPoint)
                        
                        let potDistance = (x2 * x2) + (y2 * y2)
                        print(potDistance)
                        
                        if let theDistance = leastDistance {
                            if (potDistance < theDistance) {
                                leastDistance = potDistance
                                nearestPoint = snapPoint
                            }
                        } else {
                            leastDistance = potDistance
                            nearestPoint = snapPoint
                        }
                        
                    }
                    
                }
                
                return nearestPoint
                
            }
        }
        
        return CGPoint(x: -1, y: -1)
    }

    public func getDownYSnapPoint(currentPoint: CGPoint) -> CGPoint {
        if let measureCoord = selectedMeasureCoord {
            
            var nearestPoint:CGPoint = currentPoint
            var leastDistance:CGFloat?
            if let snapPoints = snapPointsMap[measureCoord] {
                
                for (index, snapPoint) in snapPoints.enumerated() {
                    
                    if (snapPoint.y > currentPoint.y && snapPoint != currentPoint && snapPoint.x == currentPoint.x) {
                        let x2: CGFloat = currentPoint.x - snapPoint.x
                        let y2: CGFloat = currentPoint.y - snapPoint.y
                        
                        print(index)
                        print(snapPoint)
                        
                        let potDistance = (x2 * x2) + (y2 * y2)
                        print(potDistance)
                        
                        if let theDistance = leastDistance {
                            if (potDistance < theDistance) {
                                leastDistance = potDistance
                                nearestPoint = snapPoint
                            }
                        } else {
                            leastDistance = potDistance
                            nearestPoint = snapPoint
                        }
                        
                    }
                    
                }
                
                return nearestPoint
                
            }
        }
        
        return CGPoint(x: -1, y: -1)
    }

    public func createSnapPoints (initialX: CGFloat, initialY: CGFloat, clef:Clef) -> [CGPoint] {
        var snapPoints = [CGPoint]()

        var currSnapPoint:CGPoint = CGPoint(x: initialX, y: initialY)

        var pitchArray = [Pitch]()

        switch clef {
            case .G:
                pitchArray = gClefPitches
            case .F:
                pitchArray = fClefPitches
        }

        for i in 1...9 {
            snapPoints.append(currSnapPoint)
            YPitchMap[currSnapPoint.y] = pitchArray[i-1]

            if i % 2 == 0 {
                currSnapPoint = CGPoint(x: currSnapPoint.x, y: currSnapPoint.y + 16.5)
            } else {
                currSnapPoint = CGPoint(x: currSnapPoint.x, y: currSnapPoint.y + 13.5)
            }
        }

        return snapPoints
    }

    public func getNotePlacement (notation: MusicNotation) -> (CGPoint, CGPoint) {

        var isUpwards = true

        if let note = notation as? Note {
            isUpwards = note.isUpwards
        }

        if let measureCoord = selectedMeasureCoord {

            if let weights = weightsMap[measureCoord] {

                // for 4/4
                let maximum64s = GridSystem.getMaximum64s(timeSig: TimeSignature())

                if let coord = selectedCoord {
                    
                    if let currIndex = weights.index(of: CGPoint(x:coord.x, y:measureCoord.lowerRightPoint.y)) {

                        var endPoint:CGPoint

                        switch notation.type {
                        case .sixtyFourth:
                            if isUpwards {
                                return (CGPoint(x: coord.x, y: coord.y - 30), weights[currIndex + 1])
                            } else {
                                return (CGPoint(x: coord.x, y: coord.y), weights[currIndex + 1])
                            }
                        case .thirtySecond:
                            endPoint = weights[currIndex + (maximum64s / 32 - 1)]
                        case .sixteenth:
                            endPoint = weights[currIndex + (maximum64s / 16 - 1)]
                        case .eighth:
                            endPoint = weights[currIndex + (maximum64s / 8 - 1)]
                        case .quarter:
                            endPoint = weights[currIndex + (maximum64s / 4 - 1)]
                        case .half:
                            endPoint = weights[currIndex + (maximum64s / 2 - 1)]
                        case .whole:
                            endPoint = weights[currIndex + (maximum64s - 1)]
                        }

                        if notation is Rest {
                            let middlePoint = (measureCoord.upperLeftPoint.y + measureCoord.lowerRightPoint.y) / 2
                            return (CGPoint(x: (endPoint.x + weights[currIndex].x) / 2, y: middlePoint-30 ), endPoint)

                        } else if isUpwards && notation.type != .whole {
                            return (CGPoint(x: (endPoint.x + weights[currIndex].x) / 2, y: coord.y - 30), endPoint)
                        } else {
                            return (CGPoint(x: (endPoint.x + weights[currIndex].x) / 2, y: coord.y), endPoint)
                        }

                    }
                }

            }
        }

        return (CGPoint(x: -1, y: -1), CGPoint(x: -1, y: -1))
    }

    // THIS IS FOR RELOADING THE WHOLE COMPOSITION
    public func getNotePlacement (notation: MusicNotation, clef: Clef, snapPoints: [CGPoint], weights: [CGPoint]) -> (CGPoint, CGPoint) {

        var pitchToPointMap = [Pitch: CGPoint]()
        let pitches = getPitches(clef: clef)

        var isUpwards = true

        if let note = notation as? Note {

            isUpwards = note.isUpwards

            for i in 0..<snapPoints.count {
                print(pitches[i])
                pitchToPointMap[pitches[i]] = snapPoints[i]
            }

            var endPoint: CGPoint

            if let corresPoint = pitchToPointMap[note.pitch] {

                if let currIndex = weights.index(where: { $0.x == snapPoints[0].x }) {

                    // TODO : get time signature
                    let maximum64s = GridSystem.getMaximum64s(timeSig: TimeSignature())

                    switch notation.type {
                    case .sixtyFourth:
                        if isUpwards {
                            return (CGPoint(x: corresPoint.x, y: corresPoint.y - 30), weights[currIndex + 1])
                        } else {
                            return (CGPoint(x: corresPoint.x, y: corresPoint.y), weights[currIndex + 1])
                        }
                    case .thirtySecond:
                        endPoint = weights[currIndex + (maximum64s / 32 - 1)]
                    case .sixteenth:
                        endPoint = weights[currIndex + (maximum64s / 16 - 1)]
                    case .eighth:
                        endPoint = weights[currIndex + (maximum64s / 8 - 1)]
                    case .quarter:
                        endPoint = weights[currIndex + (maximum64s / 4 - 1)]
                    case .half:
                        endPoint = weights[currIndex + (maximum64s / 2 - 1)]
                    case .whole:
                        endPoint = weights[currIndex + (maximum64s - 1)]
                    }

                    if isUpwards && notation.type != .whole {
                        return (CGPoint(x: (endPoint.x + weights[currIndex].x) / 2, y: corresPoint.y - 30), endPoint)
                    } else {
                        return (CGPoint(x: (endPoint.x + weights[currIndex].x) / 2, y: corresPoint.y), endPoint)
                    }

                }

            } else if notation is Rest {
                // TODO: PLACING OF REST
            }

        }

        return (CGPoint(x: -1, y: -1), CGPoint(x: -1, y: -1))

    }

    public static func getMaximum64s (timeSig: TimeSignature) -> Int {
        return (64/timeSig.beatType) * timeSig.beats
    }

    public func getPitches (clef: Clef) -> [Pitch] {

        if clef == .F {
            return fClefPitches
        } else {
            return gClefPitches
        }

    }
    
    struct MeasurePoints : Hashable {
        var upperLeftPoint:CGPoint
        var lowerRightPoint:CGPoint
        
        public var hashValue: Int {
            return upperLeftPoint.x.hashValue ^ upperLeftPoint.y.hashValue ^ lowerRightPoint.x.hashValue ^ lowerRightPoint.y.hashValue
        }
        
        public static func == (lhs: MeasurePoints, rhs: MeasurePoints) -> Bool {
            return lhs.upperLeftPoint.x == rhs.upperLeftPoint.x &&
                lhs.upperLeftPoint.y == rhs.upperLeftPoint.y &&
                lhs.lowerRightPoint.x == rhs.lowerRightPoint.x &&
                lhs.lowerRightPoint.y == rhs.lowerRightPoint.y
        }
    }
    
}
