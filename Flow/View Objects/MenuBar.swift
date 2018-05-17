//
//  MenuBar.swift
//  Flow
//
//  Created by Kevin Chan on 12/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class MenuBar: UIView {
    
//    @IBOutlet weak var compositionTitleButton: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var naturalizeBtn: UIButton!
    @IBOutlet weak var flatBtn: UIButton!
    @IBOutlet weak var sharpBtn: UIButton!
    @IBOutlet weak var dSharpBtn: UIButton!
    
    @IBOutlet weak var oneDotBtn: UIButton!
    @IBOutlet weak var twoDotsBtn: UIButton!
    @IBOutlet weak var threeDotsBtn: UIButton!
    
    let maxNumOfDots = 3

    /*var compositionInfo: CompositionInfo? {
        didSet {
            self.compositionTitleButton.setTitle(compositionInfo?.name, for: .normal)
        }
    }*/

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

        EventBroadcaster.instance.removeObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "MenuBar.stop", function: self.stop))
        EventBroadcaster.instance.addObserver(event: EventNames.STOP_PLAYBACK, observer: Observer(id: "MenuBar.stop", function: self.stop))

        EventBroadcaster.instance.removeObserver(event: EventNames.DISABLE_ACCIDENTALS, observer: Observer(id: "MenuBar.disableAccidentals", function: self.disableAccidentals))
        EventBroadcaster.instance.addObserver(event: EventNames.DISABLE_ACCIDENTALS, observer: Observer(id: "MenuBar.disableAccidentals", function: self.disableAccidentals))

        EventBroadcaster.instance.removeObserver(event: EventNames.ENABLE_ACCIDENTALS, observer: Observer(id: "MenuBar.enableAccidentals", function: self.enableAccidentals))
        EventBroadcaster.instance.addObserver(event: EventNames.ENABLE_ACCIDENTALS, observer: Observer(id: "MenuBar.enableAccidentals", function: self.enableAccidentals))

        EventBroadcaster.instance.removeObserver(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, observer: Observer(id: "MenuBar.highlightAccidentalBtn", function: self.highlightAccidentalBtn))
        EventBroadcaster.instance.addObserver(event: EventNames.HIGHLIGHT_ACCIDENTAL_BTN, observer: Observer(id: "MenuBar.highlightAccidentalBtn", function: self.highlightAccidentalBtn))

        EventBroadcaster.instance.removeObserver(event: EventNames.REMOVE_ACCIDENTAL_HIGHLIGHT, observer: Observer(id: "MenuBar.removeAccidentalHighlight", function: self.removeAccidentalHighlight))
        EventBroadcaster.instance.addObserver(event: EventNames.REMOVE_ACCIDENTAL_HIGHLIGHT, observer: Observer(id: "MenuBar.removeAccidentalHighlight", function: self.removeAccidentalHighlight))
        
        EventBroadcaster.instance.removeObserver(event: EventNames.UPDATE_INVALID_DOTS, observer: Observer(id: "MenuBar.updateInvalidDots", function: self.updateInvalidDots))
        EventBroadcaster.instance.addObserver(event: EventNames.UPDATE_INVALID_DOTS, observer: Observer(id: "MenuBar.updateInvalidDots", function: self.updateInvalidDots))
    }

    func highlightAccidentalBtn(params: Parameters) {
        if let accidental: Accidental = params.get(key: KeyNames.ACCIDENTAL) as! Accidental {

            print("ACCIDENTAL: \(accidental.toString())")

            if accidental == .natural {
                self.naturalizeBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            } else if accidental == .sharp {
                self.sharpBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            } else if accidental == .flat {
                self.flatBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            } else if accidental == .doubleSharp {
                self.dSharpBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            }
        }
    }

    func removeAccidentalHighlight() {
        self.naturalizeBtn.backgroundColor = nil
        self.sharpBtn.backgroundColor = nil
        self.flatBtn.backgroundColor = nil
        self.dSharpBtn.backgroundColor = nil
    }

    /*@IBAction func touchCompositionTitle(_ sender: UIButton) {
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
    }*/

    @IBAction func touchCopy(_ sender: UIButton) {
        EventBroadcaster.instance.postEvent(event: EventNames.COPY_KEY_PRESSED)
    }

    @IBAction func touchCut(_ sender: UIButton) {
        EventBroadcaster.instance.postEvent(event: EventNames.CUT_KEY_PRESSED)
    }
    
    @IBAction func touchPaste(_ sender: UIButton) {
        EventBroadcaster.instance.postEvent(event: EventNames.PASTE_KEY_PRESSED)
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

    func disableAccidentals() {
        self.naturalizeBtn.isUserInteractionEnabled = false
        self.flatBtn.isUserInteractionEnabled = false
        self.sharpBtn.isUserInteractionEnabled = false
        self.dSharpBtn.isUserInteractionEnabled = false
    }

    func enableAccidentals() {
        self.naturalizeBtn.isUserInteractionEnabled = true
        self.flatBtn.isUserInteractionEnabled = true
        self.sharpBtn.isUserInteractionEnabled = true
        self.dSharpBtn.isUserInteractionEnabled = true
    }
    
    @IBAction func touchNaturalize(_ sender: UIButton) {
        print("naturalize")
        self.removeAccidentalHighlight()
        EventBroadcaster.instance.postEvent(event: EventNames.NATURALIZE_KEY_PRESSED)
    }
    
    @IBAction func touchFlat(_ sender: UIButton) {
        print("flat")
        self.removeAccidentalHighlight()
        EventBroadcaster.instance.postEvent(event: EventNames.FLAT_KEY_PRESSED)
    }
    
    @IBAction func touchSharp(_ sender: UIButton) {
        print("sharp")
        self.removeAccidentalHighlight()
        EventBroadcaster.instance.postEvent(event: EventNames.SHARP_KEY_PRESSED)
    }

    @IBAction func touchDSharp(_ sender: UIButton) {
        print("dsharp")
        self.removeAccidentalHighlight()
        EventBroadcaster.instance.postEvent(event: EventNames.DSHARP_KEY_PRESSED)
    }
    
    @IBAction func touchUndo(_ sender: UIButton) {
        UndoRedoManager.instance.undo()
    }
    
    @IBAction func touchRedo(_ sender: UIButton) {
        UndoRedoManager.instance.redo()
    }
    
    @IBAction func touchOneDot(_ sender: UIButton) {
        print("ONE DOT")
        
        let params = Parameters()
        params.put(key: KeyNames.NUM_OF_DOTS, value: 1)
        
        EventBroadcaster.instance.postEvent(event: EventNames.DOT_KEY_PRESSED, params: params)
    }
    
    @IBAction func touchTwoDots(_ sender: UIButton) {
        print("Two DOT")
        
        let params = Parameters()
        params.put(key: KeyNames.NUM_OF_DOTS, value: 2)
        
        EventBroadcaster.instance.postEvent(event: EventNames.DOT_KEY_PRESSED, params: params)
    }
    
    @IBAction func touchThreeDots(_ sender: UIButton) {
        print("Three DOT")
        
        let params = Parameters()
        params.put(key: KeyNames.NUM_OF_DOTS, value: 3)
        
        EventBroadcaster.instance.postEvent(event: EventNames.DOT_KEY_PRESSED, params: params)
    }
    
    private func highlightDotButton(numDot: Int) {
        switch numDot {
        case 1:
            oneDotBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
        case 2:
            twoDotsBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
        case 3:
            threeDotsBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
        default:
            oneDotBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            twoDotsBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
            threeDotsBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 0.7)
        }
    }
    
    private func removeHighlightDotButton(numDot: Int) {
        switch numDot {
        case 1:
            oneDotBtn.backgroundColor = nil
        case 2:
            twoDotsBtn.backgroundColor = nil
        case 3:
            threeDotsBtn.backgroundColor = nil
        default:
            oneDotBtn.backgroundColor = nil
            twoDotsBtn.backgroundColor = nil
            threeDotsBtn.backgroundColor = nil
        }
    }
    
    private func enableDotButton(numDot: Int, enabled: Bool) {
        switch numDot {
        case 1:
            oneDotBtn.isEnabled = enabled
        case 2:
            twoDotsBtn.isEnabled = enabled
        case 3:
            threeDotsBtn.isEnabled = enabled
        default:
            oneDotBtn.isEnabled = enabled
            twoDotsBtn.isEnabled = enabled
            threeDotsBtn.isEnabled = enabled
        }
    }
    
    private func updateInvalidDots(parameters: Parameters) {
        if let selectedNotations = parameters.get(key: KeyNames.SELECTED_NOTATIONS) as? [MusicNotation] {
            
            if selectedNotations.count > 0 {
            
            var measures = [Measure]()
            var addedValueToMeasureMap = [Measure: Float]()
            var dotBools = [Int: Bool]()
        
                for dots in 1...maxNumOfDots {
                
                    var allDotsAreEqualToNumDots = true
                    
                    for notation in selectedNotations {
                        if notation.dots != dots {
                            allDotsAreEqualToNumDots = false
                        }
                    }
                    
                    if allDotsAreEqualToNumDots {
                        dotBools[dots] = true
                        
                        highlightDotButton(numDot: dots)
                    } else {
                        removeHighlightDotButton(numDot: dots)
                    
                        for notation in selectedNotations {
                            
                            if let measure = notation.measure {
                                if let existingAddedValue = addedValueToMeasureMap[measure] {
                                    addedValueToMeasureMap[measure] = existingAddedValue + (notation.type.getBeatValue(dots: dots) - notation.type.getBeatValue(dots: notation.dots))
                                } else {
                                    addedValueToMeasureMap[measure] = notation.type.getBeatValue(dots: dots) - notation.type.getBeatValue(dots: notation.dots)
                                    measures.append(measure)
                                }
                            }
                            
                        }
                        
                        for measure in measures {
                            if measure.isAddNoteValid(value: addedValueToMeasureMap[measure]!) {
                                dotBools[dots] = true
                            } else {
                                dotBools[dots] = false
                                break
                            }
                        }
                        
                    }
                    
                    enableDotButton(numDot: dots, enabled: dotBools[dots]!)
                    
                }
                
            } else {
                removeHighlightDotButton(numDot: -1)
                enableDotButton(numDot: -1, enabled: false)
            }
        }
    }
    
    @IBAction func toggleKeyboard(_ sender: UIButton) {
        EventBroadcaster.instance.postEvent(event: EventNames.TOGGLE_KEYBOARD)
        print("TOGGLE PRESSED")
    }
}
