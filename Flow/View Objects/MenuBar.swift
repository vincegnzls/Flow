//
//  MenuBar.swift
//  Flow
//
//  Created by Kevin Chan on 12/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class MenuBar: UIView {
    
    @IBOutlet weak var compositionTitleButton: UIButton!
    var compositionInfo: CompositionInfo? {
        didSet {
            self.compositionTitleButton.setTitle(compositionInfo?.name, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        // Set up shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
    }
    
    @IBAction func touchCompositionTitle(_ sender: UIButton) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Change title", message: "Enter a new title for your composition", preferredStyle: .alert)
        
        // Confirm action
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let title = alertController.textFields?[0].text
            
            if !(title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
                self.compositionTitleButton.setTitle(title, for: .normal)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        // Create a textfield for input
        alertController.addTextField { (textField) in
            textField.placeholder = self.compositionTitleButton.currentTitle
        }
        
        // Add the actions to the alert
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        // Present the dialog box
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func touchCopy(_ sender: UIButton) {
        
    }
    
    @IBAction func touchCut(_ sender: UIButton) {
        
    }
    
    @IBAction func touchPaste(_ sender: UIButton) {
    
    }
    
    
}
