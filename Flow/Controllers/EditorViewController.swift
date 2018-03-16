//
//  ViewController.swift
//  Flow
//
//  Created by Vince on 03/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var musicSheet: MusicSheet!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var menuBar: MenuBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var musicSheetHeight: NSLayoutConstraint!
    @IBOutlet weak var tempoBtn: UIView!
    @IBOutlet weak var tempoSliderView: UIView!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var tempoSlider: UISlider!
    
    var composition: Composition?

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
        EventBroadcaster.instance.removeObservers(event: EventNames.DELETE_KEY_PRESSED)
        EventBroadcaster.instance.addObserver(event: EventNames.DELETE_KEY_PRESSED,
                                              observer: Observer(id: "EditorViewController.onDeleteKeyPressed", function: self.onDeleteKeyPressed))
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //let params = Parameters()
        //params.put(key: KeyNames.COMPOSITION, value: self.composition!)

        //EventBroadcaster.instance.postEvent(event: EventNames.VIEW_FINISH_LOADING, params: params)

        if self.musicSheet != nil {
            // set composition in music sheet
            self.musicSheet.composition = self.composition

            if let comp = self.composition {
                if comp.staffList[0].measures.count > 6 {
                    var extraMeasuresCount = comp.staffList[0].measures.count - 6

                    extraMeasuresCount /= 2

                    print("EXTRA MEASURES: \(extraMeasuresCount)")

                    for _ in 0...extraMeasuresCount - 1 {
                        self.musicSheetHeight.constant = self.musicSheetHeight.constant + 520
                    }
                }
            }
        }
        
        if let menuBar = self.menuBar, let composition = self.composition {
            menuBar.compositionInfo = composition.compositionInfo
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        initTempo()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapTempo))
        self.tempoBtn.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / musicSheet.bounds.width
        let heightScale = size.height / musicSheet.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2
        scrollView.zoomScale = minScale
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapSave(_ sender: UIBarButtonItem) {
        
        if let composition = self.musicSheet.composition {
            FileHandler.instance.saveFile(composition: composition)
        }
        
    }
    
    @IBAction func tempoSliderChange(_ sender: UISlider) {
        self.tempoLabel.text = "= " + String(Int(sender.value))
        
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
    
    func initTempo() {
        
        if let comp = self.composition {
            self.tempoSliderView.isHidden = true
            self.tempoSlider.setValue(Float(comp.tempo), animated: false)
            self.tempoLabel.text = "= " + String(Int(comp.tempo))
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
                    print("at selectedNotations.count > 0")
                    editNotations(old: self.musicSheet.selectedNotations, new: [note])
                    
//                    EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
                    if let note = note as? Note {
                        SoundManager.instance.playNote(note: note)
                    }
                } else if let hovered = self.musicSheet.hoveredNotation {
                    //EditAction editAction = EditAction(old: [hovered], new: note)
                    self.editNotations(old: [hovered], new: [note])

                    addGrandStaff()
                    
                    if let note = note as? Note {
                        SoundManager.instance.playNote(note: note)
                    }
//                    EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
                } else {
                    // instantiate add action
                    let addAction = AddAction(measure: measure, notation: note)
                    
                    if let note = note as? Note {
                        SoundManager.instance.playNote(note: note)
                    }
                    
                    GridSystem.instance.recentNotation = note

                    addAction.execute()

                    addGrandStaff()
                    
//                    EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
                }
                EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
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
        }
        
        musicSheet.selectedNotations.removeAll()
        
        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
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
                print("PREV HEIGHT \(self.musicSheetHeight.constant)")
                self.musicSheetHeight.constant = self.musicSheetHeight.constant + 520
                print("UPDATED HEIGHT \(self.musicSheetHeight.constant)")
                print("LAST MEASURE FULL")
                currentComp.addGrandStaff()
            }
        }
    }
}

