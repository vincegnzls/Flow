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
    
    init(startX:CGFloat = 0, endX:CGFloat = 0, startY:CGFloat = 0, endY:CGFloat = 0) {
        self.startX = startX
        self.endX = endX
        self.startY = startY
        self.endY = endY
    }
}
