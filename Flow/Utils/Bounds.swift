//
//  Bounds.swift
//  Flow
//
//  Created by Vince on 11/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

struct Bounds {
    var startX:CGFloat
    var endX:CGFloat
    var startY:CGFloat
    var endY:CGFloat
    
    init(startX:CGFloat, endX:CGFloat, startY:CGFloat, endY:CGFloat) {
        self.startX = startX
        self.endX = endX
        self.startY = startY
        self.endY = endY
    }
    
    init() {
        self.startX = 0
        self.endX = 0
        self.startY = 0
        self.endY = 0
    }
}
