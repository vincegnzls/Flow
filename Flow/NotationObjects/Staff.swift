//
//  Staff.swift
//  Flow
//
//  Created by Vince on 19/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class Staff: UIStackView {

    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupStaff()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStaff()
    }
    
    @objc func staffTapped(button: UIButton) {
        print("Button pressed 👍")
        

    }
    
    private func setupStaff() {
        
        for _ in 0..<5 {
            let line = Line()
            addArrangedSubview(line)
            
            let space = UIButton()
            space.backgroundColor = UIColor.white
            
            line.addTarget(self, action: #selector(Staff.staffTapped(button:)), for: .touchUpInside)
            
            space.addTarget(self, action: #selector(Staff.staffTapped(button:)), for: .touchUpInside)
            
            addArrangedSubview(space)
        }
        
    }
}
