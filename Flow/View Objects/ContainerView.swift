//
//  ContainerView.swift
//  Flow
//
//  Created by Kevin Chan on 22/06/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import UIKit

class ContainerView: UIView {

    @IBInspectable var bottomHeight: CGFloat = 0
    
    var lowerBounds: CGFloat {
        return self.bounds.height - bottomHeight
    }
}
