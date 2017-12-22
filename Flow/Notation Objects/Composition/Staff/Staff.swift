//
//  Staff.swift
//  Flow
//
//  Created by Vince on 19/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class Staff {

    var isEnsemble: Bool
    var measures: [Measure]
    
    init(isEnsemble: Bool, measures: [Measure]) {
        self.isEnsemble = isEnsemble
        self.measures = measures
    }
    
    init(measures: [Measure]) {
        self.measures = measures
    }
}
