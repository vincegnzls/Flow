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

    private var staffComponents = [UIButton]()
    
    private var prevButton: UIButton?
    
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
        
        guard let index = staffComponents.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(staffComponents)")
        }
        
        for i in 0..<staffComponents.count{
            staffComponents[i].backgroundColor = UIColor.white
        }
    
        staffComponents[index].backgroundColor = UIColor(red:0.25, green:0.41, blue:0.88, alpha:0.75)
    }
    
    private func setupStaff() {
        
        for _ in 0..<5 {
            let line = Line()
            addArrangedSubview(line)
            
            let space = UIButton()
            space.backgroundColor = UIColor.white
            addArrangedSubview(space)
            
            line.addTarget(self, action: #selector(Staff.staffTapped(button:)), for: .touchUpInside)
            
            space.addTarget(self, action: #selector(Staff.staffTapped(button:)), for: .touchUpInside)
            
            staffComponents.append(line)
            staffComponents.append(space)
        }
        
    }
}
