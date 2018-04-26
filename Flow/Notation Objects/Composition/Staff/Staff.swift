//
//  Staff.swift
//  Flow
//
//  Created by Vince on 19/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class Staff {

    var measures: [Measure]
    
    init(measures: [Measure] = []) {
        self.measures = measures
    }

    func addMeasure(_ measure: Measure) {
        self.measures.append(measure)
    }

    func removeAllNotes() {
        for measure in self.measures {
            measure.removeAllNotations()
        }
    }

    func duplicate() -> Staff {
        return Staff(measures: self.measures)
    }
}
