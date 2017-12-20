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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let measure = Measure(keySignature: KeySignature.c,
                              timeSignature: TimeSignature(),
                              clef: Clef.G)
        measure.notationObjects.append(Note(pitch: Pitch(step: Step.A, octave: 2),
                                            type: RestNoteType.quarter,
                                            clef: Clef.G))
        measure.notationObjects.append(Rest(type: .half))
        
        var measures = [Measure]()
        measures.append(measure)
        let comp = Composition(measures: measures)
        let test = FileHandler.instance.convertCompositionToMusicXML(comp)
        
        print("\(test)")
        
        FileHandler.instance.convertMusicXMLtoComposition(test)
    }
}

