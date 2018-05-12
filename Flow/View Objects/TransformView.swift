//
//  TransformView.swift
//  Flow
//
//  Created by Vince on 11/05/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import UIKit

class TransformView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.frame = CGRect()
    }

}
