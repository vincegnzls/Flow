//
//  Music Sheet.swift
//  Flow
//
//  Created by Vince on 19/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class Music_Sheet: UIStackView {

    override init(frame: CGRect) {
        super.init(frame:frame)
        setupSheet()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupSheet()
    }

    private func setupSheet() {
        let staff = Staff()
        
        addArrangedSubview(staff)
    }
}
