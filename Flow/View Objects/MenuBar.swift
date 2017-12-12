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
    
    func showInputDialog() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Change title", message: "Enter a new title for your composition", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let title = alertController.textFields?[0].text
            
            //getting the input values from user
            //let name = alertController.textFields?[0].text
            //let email = alertController.textFields?[1].text
            
            //self.labelMessage.text = "Name: " + name! + "Email: " + email!
            
            if !(title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
                self.compositionTitleButton.setTitle(title, for: .normal)
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = self.compositionTitleButton.currentTitle
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func touchCompositionTitle(_ sender: UIButton) {
        self.showInputDialog()
    }
}
