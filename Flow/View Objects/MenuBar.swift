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
    @IBOutlet weak var playBtn: UIButton!
    
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

        EventBroadcaster.instance.removeObservers(event: EventNames.STOP_PLAYBACK)
        EventBroadcaster.instance.addObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "MusicSheet.stop", function: self.stop))
    }
    
    @IBAction func touchCompositionTitle(_ sender: UIButton) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Change title", message: "Enter a new title for your composition", preferredStyle: .alert)
        
        // Confirm action
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let title = alertController.textFields?[0].text
            
            if !(title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! {
                self.compositionTitleButton.setTitle(title, for: .normal)
                let params = Parameters()
                params.put(key: KeyNames.NEW_TITLE, value: title!)
                EventBroadcaster.instance.postEvent(event: EventNames.TITLE_CHANGED, params: params)
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
        EventBroadcaster.instance.postEvent(event: EventNames.COPY_KEY_PRESSED)
    }
    
    @IBAction func touchCut(_ sender: UIButton) {
        EventBroadcaster.instance.postEvent(event: EventNames.CUT_KEY_PRESSED)
    }
    
    @IBAction func touchPlay(_ sender: UIButton) {
        EventBroadcaster.instance.postEvent(event: EventNames.PLAY_KEY_PRESSED)

        SoundManager.instance.isPlaying = !SoundManager.instance.isPlaying

        if SoundManager.instance.isPlaying {
            if let image = UIImage(named: "stop-icon") {
                playBtn.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: "play-icon") {
                playBtn.setImage(image, for: .normal)
            }
        }
    }

    func stop() {
        if let image = UIImage(named: "play-icon") {
            playBtn.setImage(image, for: .normal)
        }
    }
    
    @IBAction func touchPaste(_ sender: UIButton) {
        EventBroadcaster.instance.postEvent(event: EventNames.PASTE_KEY_PRESSED)
    }
    
    @IBAction func touchNaturalize(_ sender: UIButton) {
        print("naturalize")
        EventBroadcaster.instance.postEvent(event: EventNames.NATURALIZE_KEY_PRESSED)
    }
    
    @IBAction func touchFlat(_ sender: UIButton) {
        print("flat")
        EventBroadcaster.instance.postEvent(event: EventNames.FLAT_KEY_PRESSED)
    }
    
    @IBAction func touchSharp(_ sender: UIButton) {
        print("sharp")
        EventBroadcaster.instance.postEvent(event: EventNames.SHARP_KEY_PRESSED)
    }

    @IBAction func touchDSharp(_ sender: UIButton) {
        print("dsharp")
        EventBroadcaster.instance.postEvent(event: EventNames.DSHARP_KEY_PRESSED)
    }
    
}
