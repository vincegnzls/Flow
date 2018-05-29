//
//  ViewController.swift
//  Flow
//
//  Created by Vince on 03/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    private struct Constants {
        static let keyIsBottomMenuHidden = "IsBottomMenuHidden"
    }
    
    @IBOutlet weak var musicSheet: MusicSheet!
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var musicSheetHeight: NSLayoutConstraint!
    @IBOutlet weak var musicSheetWidth: NSLayoutConstraint!
    @IBOutlet weak var tempoStackView: UIStackView!
    @IBOutlet weak var tempoSliderView: UIView!
    @IBOutlet weak var tempoTextField: UITextField!
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var titleTextField: MaxLengthTextField!
    @IBOutlet weak var bottomMenu: UIView!
    @IBOutlet weak var keyboardView: KeyboardView!
    
    var backButton : UIBarButtonItem!
    
    var composition: Composition?
    var initialTitle: String = "Untitled Composition"
    var initialXML: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        toggleKeyboard()
        
        // Revise back button
        
        // Disable the swipe to make sure you get your chance to save
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.keyboardView.isHidden = true
        
        self.tempoTextField.delegate = self
        
        //let params = Parameters()
        //params.put(key: KeyNames.COMPOSITION, value: self.composition!)
        
        //EventBroadcaster.instance.postEvent(event: EventNames.VIEW_FINISH_LOADING, params: params)
        
        if let composition = self.composition {
            self.initialTitle = composition.compositionInfo.name
            self.initialXML = Converter.compositionToMusicXML(composition)
        }
        
        if self.musicSheet != nil {
            // set composition in music sheet
            self.musicSheet.composition = self.composition
            
            if let comp = self.composition {
                if comp.staffList[0].measures.count > 3 {
                    let extraMeasuresCount = comp.staffList[0].measures.count - 3
                    
                    for _ in 0..<extraMeasuresCount {
                        self.musicSheetWidth.constant = self.musicSheetWidth.constant + 650
                    }
                }
            }
        }
        
        if let titleTextField = self.titleTextField, let compositionTitle = self.composition?.compositionInfo.name {
            titleTextField.text = compositionTitle
        }
        
        /*if let menuBar = self.menuBar, let composition = self.composition {
         menuBar.compositionInfo = composition.compositionInfo
         }*/
        
        // Do any additional setup after loading the view, typically from a nib.
        
        initTempo()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapTempo))
        self.tempoStackView.addGestureRecognizer(tapGesture)
        
        self.setupBottomMenu()
    }
    
    private func setupBottomMenu() {
        self.bottomMenu.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        
        let defaults = UserDefaults.standard
        
        let isBottomMenuHidden = defaults.bool(forKey: Constants.keyIsBottomMenuHidden)
        
        if isBottomMenuHidden {
            self.bottomMenu.transform = self.bottomMenu.transform.translatedBy(x: 0, y: 60)
        }
    }
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        // Check if there are unsaved changes
        if let composition = self.musicSheet.composition, self.initialTitle != composition.compositionInfo.name ||
            self.initialXML != Converter.compositionToMusicXML(composition){
            // Here we just remove the back button, you could also disabled it or better yet show an activityIndicator
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            
            // Show alert for confirmation
            let alertController = UIAlertController(title: "Uh-oh! You've made some changes.", message: "Do you want to save the changes made to the composition?", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
                // Save
                self.save()
                
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            }
            
            let quitAction = UIAlertAction(title: "Don't Save", style: .destructive) { (_) in
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            }
            
            // Add the actions to the alert
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            alertController.addAction(quitAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != tempoSliderView {
            hideTempo()
        }
        
        super.touchesBegan(touches, with: event)
    }

    required init?(coder aDecoder: NSCoder) {
        GridSystem.instance.reset()

        // TODO: change this to load an existing composition if did not create a new comp
        // TODO: inline number of measures per staff also
        // CREATES A NEW COMPOSITION WITH DEFAULT LAYOUT OF 12 MEASURES, 3 GRAND STAVES, AND 2 MEASURES PER STAFF
        var measuresForG = [Measure]()
        var measuresForF = [Measure]()

        for _  in 1...6 {
            let measure = Measure(loading: false)

            // dummy data
            //measure.addNoteInMeasure(Note(pitch: Pitch(step: Step.B, octave: 4), type: .eighth, clef: measure.clef))
            //measure.addNoteInMeasure(Note(pitch: Pitch(step: Step.C, octave: 5), type: .eighth, clef: measure.clef))
            //measure.addNoteInMeasure(Note(pitch: Pitch(step: Step.B, octave: 4), type: .eighth, clef: measure.clef))
            //measure.addNoteInMeasure(Note(pitch: Pitch(step: Step.C, octave: 5), type: .eighth, clef: measure.clef))

            measuresForG.append(measure)
        }

        for _ in 1...6 {
            measuresForF.append(Measure(clef: Clef.F, loading: false))
        }

        let GStaff = Staff(measures: measuresForG)
        let FStaff = Staff(measures: measuresForF)

        var staffArr = [Staff]()

        staffArr.append(GStaff)
        staffArr.append(FStaff)

        composition = Composition(staffList: staffArr)

        // END OF CREATION

        // init
        super.init(coder: aDecoder)

        EventBroadcaster.instance.removeObservers(event: EventNames.NOTATION_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.NOTATION_KEY_PRESSED,
                observer: Observer(id: "EditorViewController.onNoteKeyPressed", function: self.onNoteKeyPressed))
        EventBroadcaster.instance.removeObservers(event: EventNames.ADD_GRAND_STAFF)
        EventBroadcaster.instance.addObserver(event: EventNames.ADD_GRAND_STAFF,
                observer: Observer(id: "EditorViewController.addGrandStaff", function: self.addGrandStaff))
        EventBroadcaster.instance.removeObservers(event: EventNames.HIDE_TEMPO_MENU)
        EventBroadcaster.instance.addObserver(event: EventNames.HIDE_TEMPO_MENU,
                                              observer: Observer(id: "EditorViewController.hideTempo", function: self.hideTempo))
        EventBroadcaster.instance.removeObservers(event: EventNames.DELETE_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.DELETE_KEY_PRESSED,
                                              observer: Observer(id: "EditorViewController.onDeleteKeyPressed", function: self.onDeleteKeyPressed))
        EventBroadcaster.instance.removeObserver(event: EventNames.TOGGLE_KEYBOARD, observer: Observer(id: "EditorViewController.toggleKeyboard", function: self.toggleKeyboard))
        EventBroadcaster.instance.addObserver(event: EventNames.TOGGLE_KEYBOARD, observer: Observer(id: "EditorViewController.toggleKeyboard", function: self.toggleKeyboard))
        EventBroadcaster.instance.removeObserver(event: EventNames.PLAY_KEY_PRESSED, observer: Observer(id: "EditorViewController.hideViews", function: self.hideViews))
        EventBroadcaster.instance.addObserver(event: EventNames.PLAY_KEY_PRESSED, observer: Observer(id: "EditorViewController.hideViews", function: self.hideViews))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / musicSheet.bounds.width
        let heightScale = size.height / musicSheet.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.maximumZoomScale = 2
        scrollView.zoomScale = minScale
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapSave(_ sender: UIBarButtonItem) {
        self.save()
    }

    public func hideViews() {
        self.keyboardView.isHidden = true
        scrollView.minimumZoomScale = 1.0
    }

    public func toggleKeyboard() {
        self.keyboardView.isHidden = !self.keyboardView.isHidden
    }
    
    private func save() {
        if let composition = self.musicSheet.composition {
            if FileHandler.instance.saveFile(composition: composition) {
                self.view.hideAllToasts()
                self.view.makeToast("Saved successfully", duration: 1.5, position: .bottom, image: UIImage(named: "save-icon-white"))
                
                self.initialTitle = composition.compositionInfo.name
                self.initialXML = Converter.compositionToMusicXML(composition)
            }
        }
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        if let comp = self.composition {
            if let tempo = Double(sender.text!) {
                comp.tempo = tempo
            }
        }
    }
    
    @IBAction func tempoSliderChange(_ sender: UISlider) {
        self.tempoTextField.text = String(Int(sender.value))
        
        if let comp = self.composition {
            comp.tempo = Double(sender.value)
        }
    }
    
    @objc func tapTempo() {
        if self.tempoSliderView.isHidden {
            self.tempoSliderView.isHidden = false
            UIView.animate(withDuration: 0.1, animations: {
                self.tempoSliderView.alpha = 0.8
            }, completion:  nil)
        } else {
            UIView.animate(withDuration: 0.1, animations: {
                self.tempoSliderView.alpha = 0
            }, completion:  {
                (value: Bool) in
                self.tempoSliderView.isHidden = true
            })
        }
    }
    
    func hideTempo() {
        // Close text fields
        self.titleTextField?.endEditing(true)
        self.tempoTextField?.endEditing(true)
        
        if !self.tempoSliderView.isHidden {
            UIView.animate(withDuration: 0.1, animations: {
                self.tempoSliderView.alpha = 0
            }, completion:  {
                (value: Bool) in
                self.tempoSliderView.isHidden = true
            })
        }
    }
    
    func initTempo() {
        
        if let comp = self.composition {
            self.tempoSliderView.isHidden = true
            self.tempoSlider.setValue(Float(comp.tempo), animated: false)
            self.tempoTextField.text = String(Int(comp.tempo))
        }
    }

    func onNoteKeyPressed (params:Parameters) {

        let restNoteType: RestNoteType = params.get(key: KeyNames.NOTE_KEY_TYPE) as! RestNoteType
        let isRest = params.get(key: KeyNames.IS_REST_KEY, defaultValue: false)

        let note: MusicNotation

        let parameters = Parameters()

        // check if there is a selected measure coord
        if let measureCoord = GridSystem.instance.selectedMeasureCoord {

            // check if there is a corresponding measure for the measure coordinate
            if let measure: Measure = GridSystem.instance.getMeasureFromPoints(
                    measurePoints: measureCoord) {


                // determine if rest or note
                if isRest {
                    note = Rest(type: restNoteType)
                } else {
                    // TODO: determine what is the correct pitch from the cursor's location
                    if let coord = GridSystem.instance.selectedCoord {
                        //let pitch = GridSystem.instance.getPitchFromY(y: coord.y)
//                        note = Note(pitch: Pitch(step: pitch.step, octave: pitch.octave), type: restNoteType)
                        note = Note(pitch: GridSystem.instance.getPitchFromY(y: coord.y), type: restNoteType)
                    } else {
                        note = Note(pitch: Pitch(step: Step.G, octave: 5), type: restNoteType)
                    }
                }

                parameters.put(key: KeyNames.NOTE_DETAILS, value: note)

                if musicSheet.selectedNotations.count > 0 {
                    //edit selected notes
                    editNotations(old: self.musicSheet.selectedNotations, new: [note])
                    
//                    EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
                    if let note = note as? Note {
                        SoundManager.instance.playNote(note: note, keySignature: measure.keySignature)
                    }
                } else if let hovered = self.musicSheet.hoveredNotation {
                    //EditAction editAction = EditAction(old: [hovered], new: note)
                    
                    GridSystem.instance.recentNotation = note
                    
                    self.editNotations(old: [hovered], new: [note])

                    addGrandStaff()
                    
                    if let note = note as? Note {
                        SoundManager.instance.playNote(note: note, keySignature: measure.keySignature)
                    }
//                    EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
                } else if let notation = GridSystem.instance.getNoteFromX(x: musicSheet.sheetCursor.curYCursorLocation.x) {
                    // if cursor has a note above or below it, then CREATE CHORD
                    
                    if notation.type != note.type || (notation is Rest && note is Note) || (notation is Note && note is Rest) {
                        if let noteFromX = notation as? Note {
                            if let chord = noteFromX.chord {
                                self.editNotations(old: [chord], new: [note])
                            } else {
                                self.editNotations(old: [notation], new: [note])
                            }
                        } else {
                            self.editNotations(old: [notation], new: [note])
                        }
                        
                        if let note = note as? Note {
                            SoundManager.instance.playNote(note: note, keySignature: measure.keySignature)
                        }
                    } else if let note = note as? Note {
                    
                        note.measure = measure
                        var newChord: Chord = Chord(type: note.type, note: note)
                    
                        if let existingNote = notation as? Note {
                            
                            // if cursor follows an existing CHORD, pour those existing elements to new chord
                            if let chord = existingNote.chord {
                                
                                newChord = chord.duplicate()
                                newChord.notes.append(note)
                                
                            // if cursor follows an existing NOTE, put that existing element to new chord
                            } else {
                                let duplicatedNote = existingNote.duplicate()
                                
                                if duplicatedNote.dots > 0 {
                                    newChord.dots = duplicatedNote.dots
                                }
                                
                                newChord.notes.append(duplicatedNote)
                            }
                        }
                        
                        if let note = notation as? Note {
                            
                            newChord.sortNotes()
                            
                            if let oldChord = note.chord {
                                self.editNotations(old: [oldChord], new: [newChord])
                            } else {
                                self.editNotations(old: [notation], new: [newChord])
                            }
                        }
                        
                        for note in newChord.notes {
                            note.chord = newChord
                        }
                        
                        SoundManager.instance.playNote(note: note, keySignature: measure.keySignature)
                    }
                    
                } else {
                    
                    // instantiate add action
                    
                    addNotation(measure: measure, notation: note)

                    addGrandStaff()
                    
                }
                
                
            }

        }

    }
    
    func getNoteMeasures(notes: [MusicNotation]) -> [Measure] {
        var measures = [Measure]()
        
        for note in notes {
            if let measure = composition?.getMeasureOfNote(note: note) {
                measures.append(measure)
            }
        }
        
        return measures
    }
    
    func addNotation(measure: Measure, notation: MusicNotation) {
        let dotMode = musicSheet.getCurrentDotMode()
        
        if dotMode > 0 {
            notation.dots = dotMode
        }

        if let note = notation as? Note {
            if let ottava: OttavaType = self.musicSheet.getCurrentOttavaMode() {
                note.ottava = ottava
            }

            if let accidental: Accidental = self.musicSheet.getCurrentAccidentalMode() {
                note.accidental = accidental
            }
        }
        
        let addAction = AddAction(measure: measure, notation: notation)
        
        if let note = notation as? Note {
            SoundManager.instance.playNote(note: note, keySignature: measure.keySignature)
        }
        
        GridSystem.instance.recentNotation = notation
        
        addAction.execute()
        
        let params = Parameters()
        params.put(key: KeyNames.ACTION_DONE, value: addAction)
        params.put(key: KeyNames.ACTION_TYPE, value: ActionFunctions.EXECUTE)
        EventBroadcaster.instance.postEvent(event: EventNames.ACTION_PERFORMED, params: params)
        
        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
    }
    
    func editNotations(old: [MusicNotation], new: [MusicNotation]) {
        //let oldNotes = musicSheet.selectedNotations
        //let noteMeasures = getNoteMeasures(notes: oldNotes)
        
        let editAction = EditAction(old: old, new: new)
        editAction.execute()
        self.musicSheet.selectedNotations.removeAll()
        
        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
    }
    
    func onDeleteKeyPressed () {
        let selectedNotes = musicSheet.selectedNotations
        //let noteMeasures = getNoteMeasures(notes: selectedNotes)
        
        if !musicSheet.selectedNotations.isEmpty {
            GridSystem.instance.recentNotation = nil
            
            let delAction = DeleteAction(notations: selectedNotes)
            delAction.execute()
        } else if let notation = musicSheet.hoveredNotation {
            GridSystem.instance.recentNotation = nil
            
            let delAction = DeleteAction(notations: [notation])
            delAction.execute()
        } else if let currentPoint = GridSystem.instance.selectedCoord {
            if let notationRelativeFromX = GridSystem.instance.getNoteFromX(x: currentPoint.x) {
                if let note = notationRelativeFromX as? Note {
                    if let chord = note.chord {
                        let delAction = DeleteAction(notations: [chord])
                        delAction.execute()
                    } else {
                        let delAction = DeleteAction(notations: [note])
                        delAction.execute()
                    }
                }
            }
        }
        
        musicSheet.selectedNotations.removeAll()
        
        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.minimumZoomScale = 0.6
        
        if musicSheet.frame.width <= scrollView.frame.width {
            let shiftWidth = scrollView.frame.width/2.0 - scrollView.contentSize.width/2.0
            scrollView.contentInset.left = shiftWidth
        } else { scrollView.contentInset.top = 0 }
        
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.musicSheet
    }

    func addGrandStaff() {
        if let currentComp = self.musicSheet.composition {
            if currentComp.isLastMeasureFull() {
                self.musicSheetWidth.constant = self.musicSheetWidth.constant + 520
                currentComp.addGrandStaff()
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    
    @IBAction func onTitleChanged(_ sender: MaxLengthTextField) {
        let title: String
        if let textFieldText = sender.text, !textFieldText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            title = textFieldText
        } else {
            title = "Untitled Composition"
        }
        
        sender.text = title
        
        let params = Parameters()
        params.put(key: KeyNames.NEW_TITLE, value: title)
        EventBroadcaster.instance.postEvent(event: EventNames.TITLE_CHANGED, params: params)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tempoTextField.endEditing(true)
        return false
    }
    
    @IBAction func onTouchHideButton(_ sender: UIButton) {
//        self.bottomMenu.isHidden = true
        let originalTransform = self.bottomMenu.transform
        let translatedTransform = originalTransform.translatedBy(x: 0, y: 60)
        
        UIView.transition(with: self.bottomMenu, duration: 0.3, animations: {
            self.bottomMenu.transform = translatedTransform
//            self.bottomMenu.isHidden = true
        })
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: Constants.keyIsBottomMenuHidden)
    }
    
    @IBAction func onTouchShowButton(_ sender: UIButton) {
//        self.bottomMenu.isHidden = false;
        
        let originalTransform = self.bottomMenu.transform
        let translatedTransform = originalTransform.translatedBy(x: 0, y: -60)
        
        UIView.transition(with: self.bottomMenu, duration: 0.3, animations: {
            self.bottomMenu.transform = translatedTransform
//            self.bottomMenu.isHidden = false
        })
        
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: Constants.keyIsBottomMenuHidden)
    }

}

