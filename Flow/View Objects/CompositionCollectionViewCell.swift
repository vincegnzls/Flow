//
//  CompositionCollectionViewCell.swift
//  Flow
//
//  Created by Kevin Chan on 24/01/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import UIKit

class CompositionCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "CompositionCollectionViewCell"

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
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
        self.layer.masksToBounds = false

        let bgColorView = UIView()
        bgColorView.backgroundColor = self.tintColor.withAlphaComponent(0.2)
        self.selectedBackgroundView = bgColorView
    }
}
