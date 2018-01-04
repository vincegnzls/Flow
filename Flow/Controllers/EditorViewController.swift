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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var menuBar: MenuBar!

    private let composition: Composition?

    required init?(coder aDecoder: NSCoder) {

        // TODO: change this to load an existing composition if did not create a new comp
        // TODO: inline number of measures per staff also
        // CREATES A NEW COMPOSITION WITH DEFAULT LAYOUT OF 12 MEASURES, 3 GRAND STAVES, AND 2 MEASURES PER STAFF
        var measuresForG = [Measure]()
        var measuresForF = [Measure]()

        for _  in 1...6 {
            measuresForG.append(Measure())
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

        EventBroadcaster.instance.addObserver(event: EventNames.NOTATION_KEY_PRESSED,
                observer: Observer(id: "EditorViewController", function: self.onNoteKeyPressed))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let params = Parameters()
        params.put(key: KeyNames.COMPOSITION, value: self.composition!)

        EventBroadcaster.instance.postEvent(event: EventNames.VIEW_FINISH_LOADING, params: params)

        if musicSheet != nil {
           // musicSheet.addMusicNotation()
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
        let measure = Measure(keySignature: KeySignature.c,
                              timeSignature: TimeSignature(),
                              clef: Clef.G)
        measure.notationObjects.append(Note(pitch: Pitch(step: Step.A, octave: 2),
                                            type: RestNoteType.quarter,
                                            clef: Clef.G))
        measure.notationObjects.append(Rest(type: .half))
        
        var measures = [Measure]()
        measures.append(measure)

        //let comp = Composition(measures: measures)
        //let test = FileHandler.instance.convertCompositionToMusicXML(comp)
        
        //print("\(test)")
        
        //FileHandler.instance.convertMusicXMLtoComposition(test)
    }

    func onNoteKeyPressed (params:Parameters) {

        let restNoteType:RestNoteType = params.get(key: KeyNames.NOTE_KEY_TYPE) as! RestNoteType
        let isRest = params.get(key: KeyNames.IS_REST_KEY, defaultValue: false)

        // TODO: instantiate here the AddCommand

        if GridSystem.instance.selectedMeasureCoord! != nil {

            if isRest {
                if let measure:Measure = GridSystem.instance.getMeasureFromPoints(
                        measurePoints: (GridSystem.instance.selectedMeasureCoord)!) {
                    let rest:Rest = Rest(type: restNoteType)
                    measure.addNoteInMeasure(musicNotation: rest)
                }

            } else {
                if let measure:Measure = GridSystem.instance.getMeasureFromPoints(
                        measurePoints: (GridSystem.instance.selectedMeasureCoord)!) {
                    // TODO: locate cursor y for knowing pitch and adjust screen coordinates
                    let note:Note = Note(pitch:Pitch(step: Step.C, octave: 4), type: restNoteType, clef: measure.clef)
                    measure.addNoteInMeasure(musicNotation: note)
                }
            }

        }

    }
}

