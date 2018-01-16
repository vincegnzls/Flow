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

    public var selectedMeasureCoord:MeasurePoints? {
        didSet {
            if (oldValue != selectedMeasureCoord) {
                EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_SWITCHED)
                print ("Measure switched!")
            }
        }
    }
    public var selectedCoord:CGPoint?
    private var measureMap = [MeasurePoints: Measure]()
    private var weightsMap = [MeasurePoints: [CGPoint]]()
    private var snapPointsMap = [MeasurePoints: [CGPoint]]()
    
    private init() {
        //GridSystem.sharedInstance = self
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

    public func addMoreSnapPointsToPoints(measurePoints:MeasurePoints, snapPoints:[CGPoint]) {
        if var snapPointsFromMap = snapPointsMap[measurePoints] {
            snapPointsFromMap.append(contentsOf: snapPoints)
            snapPointsMap[measurePoints] = snapPointsFromMap
        } else {
            assignSnapPointsToPoints(measurePoints: measurePoints, snapPoint: snapPoints)
        }
    }
    public func assignWeightsToPoints(measurePoints:MeasurePoints, weights:[CGPoint]) {
        weightsMap[measurePoints] = weights
    }

    public func getRightXSnapPoint(currentPoint: CGPoint) -> CGPoint {
        if let measureCoord = selectedMeasureCoord {

            var nearestPoint:CGPoint?
            var leastDistance:CGFloat?
            if let snapPoints = snapPointsMap[measureCoord] {

                for snapPoint in snapPoints {
                    
                    if (snapPoint.y == currentPoint.y) {

                        if let nearPoint = nearestPoint {

                            if (snapPoint.x < nearPoint.x) {
                                nearestPoint = snapPoint
                            }

                        } else if (snapPoint.x > currentPoint.x) {
                            nearestPoint = snapPoint
                        } else {
                            // TODO: Create something for entering the cursor to the next below or upwards
                            nearestPoint = currentPoint
                        }

                    }
                }

                return nearestPoint!

            }
        }

        return CGPoint(x: -1, y: -1)
    }

    public func getLeftXSnapPoint(relativeY: CGFloat)/* -> CGPoint */{

    }

    public func getUpYSnapPoint(relativeX: CGFloat)/* -> CGPoint */{

    }

    public func getDownYSnapPoint(relativeX: CGFloat)/* -> CGPoint */{

    }

    public static func createSnapPoints (initialX: CGFloat, initialY: CGFloat) -> [CGPoint] {
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

    public func getNotePlacement (notation: MusicNotation) -> (CGPoint, CGPoint) {

        if let measureCoord = selectedMeasureCoord {

            if let weights = weightsMap[measureCoord] {

                // for 4/4
                let maximum64s = GridSystem.getMaximum64s(timeSig: TimeSignature())

                if let coord = selectedCoord {

                    if var currIndex = weights.index(of: CGPoint(x:coord.x, y:measureCoord.lowerRightPoint.y)) {

                        if currIndex > 1 {
                            currIndex = currIndex - 1
                        }

                        switch notation.type {
                        case .sixtyFourth:
                            return (CGPoint(x: coord.x, y: coord.y - 30), weights[currIndex+1])
                        case .thirtySecond:
                            let endPoint = weights[currIndex + (maximum64s / 32 - 1)]

                            return (CGPoint(x: (endPoint.x + weights[currIndex].x) / 2, y: coord.y - 30), endPoint)
                        case .sixteenth:
                            let endPoint = weights[currIndex + (maximum64s / 16 - 1)]

                            return (CGPoint(x: endPoint.x + weights[currIndex].x / 2, y: coord.y - 30), endPoint)
                        case .eighth:
                            let endPoint = weights[currIndex + (maximum64s / 8 - 1)]

                            return (CGPoint(x: (endPoint.x + weights[currIndex].x) / 2, y: coord.y - 30), endPoint)
                        case .quarter:
                            let endPoint = weights[currIndex + (maximum64s / 4 - 1)]

                            return (CGPoint(x: (endPoint.x + weights[currIndex].x) / 2, y: coord.y - 30), endPoint)
                        case .half:
                            let endPoint = weights[currIndex + (maximum64s / 2 - 1)]

                            return (CGPoint(x: (endPoint.x + weights[currIndex].x) / 2, y: coord.y - 30), endPoint)
                        case .whole:
                            let endPoint = weights[currIndex + (maximum64s - 1)]

                            return (CGPoint(x: (endPoint.x + weights[currIndex].x) / 2, y: coord.y), endPoint)
                        }

                    }
                }

            }
        }

        return (CGPoint(x: -1, y: -1), CGPoint(x: -1, y: -1))
    }

    public static func getMaximum64s (timeSig: TimeSignature) -> Int {
        return (64/timeSig.beatType) * timeSig.beats
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
