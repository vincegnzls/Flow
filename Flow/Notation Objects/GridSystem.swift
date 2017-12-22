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

    public var selectedMeasureCoord:MeasurePoints?
    private var measureMap = [MeasurePoints: Measure]()
    private var weightsMap = [MeasurePoints: [CGPoint]]()
    private var snapPointsMap = [MeasurePoints: [CGPoint]]()
    private var usedWeights = [CGPoint]()
    
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
