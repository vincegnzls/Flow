//
//  CompositionInfoView.swift
//  Flow
//
//  Created by Kevin Chan on 23/01/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import UIKit

@IBDesignable
class CompositionInfoView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastEditedLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("CompositionInfoView", owner: self, options: nil)
        self.addSubview(contentView)
        self.contentView.frame = self.bounds
        //self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // Set up shadow
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowOpacity = 0.1
        self.contentView.layer.shadowOffset = CGSize.zero
        self.contentView.layer.shadowRadius = 5
    }
}
