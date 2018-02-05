//
//  ViewController.swift
//  Flow
//
//  Created by Vince on 03/10/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {
    
    @IBOutlet weak var musicSheet: MusicSheet!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var menuBar: MenuBar!

    private let composition: Composition?

    required init?(coder aDecoder: NSCoder) {
        
        GridSystem.instance.reset()

        // TODO: change this to load an existing composition if did not create a new comp
        // TODO: inline number of measures per staff also
        // CREATES A NEW COMPOSITION WITH DEFAULT LAYOUT OF 12 MEASURES, 3 GRAND STAVES, AND 2 MEASURES PER STAFF
        var measuresForG = [Measure]()
        var measuresForF = [Measure]()

        for _  in 1...6 {
            let measure = Measure()

            // dummy data
            //measure.addNoteInMeasure(Note(pitch: Pitch(step: Step.C, octave: 5), type: .quarter, clef: measure.clef))
            //measure.addNoteInMeasure(Note(pitch: Pitch(step: Step.B, octave: 4), type: .quarter, clef: measure.clef))

            measuresForG.append(measure)
        }

        for _ in 1...6 {
            measuresForF.append(Measure(clef: Clef.F))
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
        EventBroadcaster.instance.addObserver(event: EventNames.DELETE_KEY_PRESSED,
                                              observer: Observer(id: "EditorViewController.onDeleteKeyPressed", function: self.onDeleteKeyPressed))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //let params = Parameters()
        //params.put(key: KeyNames.COMPOSITION, value: self.composition!)

        //EventBroadcaster.instance.postEvent(event: EventNames.VIEW_FINISH_LOADING, params: params)

        if musicSheet != nil {
            // set composition in music sheet
            musicSheet.composition = composition
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onTapSave(_ sender: UIBarButtonItem) {

        // TODO: inline this with self instance of composition

        // FOR TESTING PURPOSES ONLY
        /*let measure = Measure(keySignature: KeySignature.c,
                              timeSignature: TimeSignature(),
                              clef: Clef.G)
        measure.notationObjects.append(Note(pitch: Pitch(step: Step.A, octave: 2),
                                            type: RestNoteType.quarter,
                                            clef: Clef.G))
        measure.notationObjects.append(Rest(type: .half))
        
        var measures = [Measure]()
        measures.append(measure)*/

        //let comp = Composition(measures: measures)
        //let test = FileHandler.instance.convertCompositionToMusicXML(comp)
        
        //print("\(test)")
        
        //FileHandler.instance.convertMusicXMLtoComposition(test)
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
                        note = Note(pitch: GridSystem.instance.getPitchFromY(y: coord.y), type: restNoteType)
                    } else {
                        note = Note(pitch: Pitch(step: Step.G, octave: 5), type: restNoteType)
                    }
                }

                parameters.put(key: KeyNames.NOTE_DETAILS, value: note)

                if musicSheet.selectedNotations.count > 0 {
                    //edit selected notes
                    
                    editSelectedNotes(newNote: note)
                    
                } else {
                    // instantiate add action
                    let addAction = AddAction(measure: measure, notation: note)

                    addAction.execute()
                    
                    EventBroadcaster.instance.postEvent(event: EventNames.ADD_NEW_NOTE, params: parameters)
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
    
    func editSelectedNotes(newNote: MusicNotation) {
        let oldNotes = musicSheet.selectedNotations
        let noteMeasures = getNoteMeasures(notes: oldNotes)
        
        let editAction = EditAction(old: oldNotes, new: [newNote])
        editAction.execute()
        
        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
    }
    
    func onDeleteKeyPressed () {
        let selectedNotes = musicSheet.selectedNotations
        //let noteMeasures = getNoteMeasures(notes: selectedNotes)
                
        let delAction = DeleteAction(notations: selectedNotes)
        delAction.execute()
        
        EventBroadcaster.instance.postEvent(event: EventNames.MEASURE_UPDATE)
    }
}

