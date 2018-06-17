//
//  Clipboard.swift
//  Flow
//
//  Created by Kevin Chan on 21/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class Clipboard {
    
    // MARK: Shared instance
    static let instance = Clipboard()
    
    // MARK: Properties
    private var gNotations: [MusicNotation]
    private var fNotations: [MusicNotation]
    
    private init() {
        self.gNotations = []
        self.fNotations = []
    }
    
    private func removeAll() {
        self.gNotations.removeAll()
        self.fNotations.removeAll()
    }

    func cut(_ notations: [MusicNotation]) {
        // self.items = notations
        self.gNotations.removeAll()
        for notation in notations {
            if let measure = notation.measure {
                if measure.clef == .G {
                    self.gNotations.append(notation)
                } else {
                    self.fNotations.append(notation)
                }
            }
        }

        let deleteAction = DeleteAction(notations: notations)
        deleteAction.execute()
    }

    func copy(_ notations: [MusicNotation]) {
        self.removeAll()
        for notation in notations {
            let newNotation = notation.duplicate()
            newNotation.measure = nil
            
            if let measure = notation.measure {
                if measure.clef == .G {
                    self.gNotations.append(newNotation)
                } else {
                    self.fNotations.append(newNotation)
                }
            }
        }
    }

    func paste(measures: [Measure], atG startGIndex: Int?, atF startFIndex: Int?) {

        let startIndices = [startGIndex, startFIndex]
        let clefs = [Clef.G, Clef.F]
        var gMeasures = [Measure]()
        var fMeasures = [Measure]()

        // Separate measures into two clefs
        for measure in measures {
            if measure.clef == .G {
                gMeasures.append(measure)
            } else {
                fMeasures.append(measure)
            }
        }
        
        let measureLists = [gMeasures, fMeasures]
        
        for i in 0..<clefs.count {
            if let startIndex = startIndices[i] {
                let clef = clefs[i]
                let curMeasures = measureLists[i]
                var items = [MusicNotation]()
                
                if clef == .G {
                    items = self.gNotations
                } else {
                    items = self.fNotations
                }
                
                var noteIndex = startIndex
                var measureIndex = 0
                var oldNotations = [MusicNotation]()
                var newNotations = [MusicNotation]()
                
                for item in items {
                    if noteIndex < curMeasures[measureIndex].notationObjects.count {
                        if !curMeasures[measureIndex].isEditNoteValid(
                            old: curMeasures[measureIndex].notationObjects[noteIndex].getBeatValue(),
                            new: item.getBeatValue()) {
                            measureIndex += 1
                            noteIndex = 0
                        }
                    }
                    
                    if measureIndex >= curMeasures.count {
                        break
                    }
                    
                    let measure = curMeasures[measureIndex]
                    
                    if noteIndex < measure.notationObjects.count {
                        let oldNotation = measure.notationObjects[noteIndex]
                        
                        oldNotations.append(oldNotation)
                    }
                    
                    newNotations.append(item.duplicate())
                    
                    noteIndex += 1
                }
                
                if oldNotations.count > 0 {
                    let editAction = EditAction(old: oldNotations, new: newNotations)
                    editAction.execute()
                } else {
                    let addAction = AddAction(measures: measures, notations: newNotations)
                    addAction.execute()
                    
                    let params = Parameters()
                    params.put(key: KeyNames.ACTION_DONE, value: addAction)
                    params.put(key: KeyNames.ACTION_TYPE, value: ActionFunctions.EXECUTE)
                    EventBroadcaster.instance.postEvent(event: EventNames.ACTION_PERFORMED, params: params)
                }
            }
            
        }
    }
}
