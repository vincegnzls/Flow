//
// Created by Kevin Chan on 23/01/2018.
// Copyright (c) 2018 MusicG. All rights reserved.
//

import UIKit

class CompositionTableViewCell: UITableViewCell {

    static let cellIdentifier = "CompositionTableViewCell"
    
    @IBOutlet weak var lastEditedLabel: UILabel!
    @IBOutlet weak var nameTextField: MaxLengthTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let bgColorView = UIView()
        bgColorView.backgroundColor = self.tintColor.withAlphaComponent(0.2)
        self.selectedBackgroundView = bgColorView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
