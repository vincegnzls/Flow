//
//  Converter.swift
//  Flow
//
//  Created by Kevin Chan on 06/01/2018.
//  Copyright © 2018 MusicG. All rights reserved.
//

import Foundation

class Converter {
    
    // MARK: Conversion functions
    static func compositionToMusicXML(_ composition: Composition) -> String {
        let xml = AEXMLDocument()
        
        let scoreElement = xml.addChild(name: "score-partwise", attributes: ["version": "3.1"])
        
        // Part list
        let partListElement = scoreElement.addChild(name: "part-list")
        let scorePartElement = partListElement.addChild(name: "score-part", attributes: ["id": "P1"])
        scorePartElement.addChild(name: "part-name", value: "Music")
        
        // Part
        let partElement = scoreElement.addChild(name: "part", attributes: ["id": "P1"])
        
        print(composition.numMeasures)
        // Loop through measures
        for i in 0..<(composition.numMeasures / 2) {
            for (index, staff) in composition.staffList.enumerated() {
                let measure = staff.measures[i]
                let measureElement = partElement.addChild(name: "measure", attributes: ["number": "\(i + index + 1)"])
                
                // Set attributes
                let attributesElement = measureElement.addChild(name: "attributes")
                
                // Calculate divisions
                var divisions = 1
                for notation in measure.notationObjects {
                    divisions = max(notation.type.getDivision(), divisions)
                }
                
                // Set divisions
                attributesElement.addChild(name: "divisions", value: "\(divisions)")
                
                // Key signature
                let keyElement = attributesElement.addChild(name: "key")
                keyElement.addChild(name: "fifths", value: "\(measure.keySignature.rawValue)")
                
                // Time signature
                let timeSignatureElement = attributesElement.addChild(name: "time")
                timeSignatureElement.addChild(name: "beats", value: "\(measure.timeSignature.beats)")
                timeSignatureElement.addChild(name: "beat-type", value: "\(measure.timeSignature.beatType)")
                
                // Clef
                let clefElement = attributesElement.addChild(name: "clef")
                clefElement.addChild(name: "sign", value: measure.clef.rawValue)
                clefElement.addChild(name: "line", value: "\(measure.clef.getStandardLine())")
                
                // Add notes and/or rests
                for notation in measure.notationObjects {
                    let notationElement = measureElement.addChild(name: "note")
                    
                    // Add necessary elements depending on note or rest
                    if let note = notation as? Note {
                        let pitchElement = notationElement.addChild(name: "pitch")
                        pitchElement.addChild(name: "step", value: note.pitch.step.toString())
                        pitchElement.addChild(name: "octave", value: "\(note.pitch.octave)")
                    } else if notation is Rest {
                        notationElement.addChild(name: "rest")
                    }
                    
                    // Set duration and type
                    notationElement.addChild(name: "duration", value: "\(notation.type.getDuration(divisions: divisions))")
                    notationElement.addChild(name: "type", value: notation.type.toString())
                }
            }
        }
        /*for (index, measure) in composition.measures.enumerated() {
         let measureElement = partElement.addChild(name: "measure", attributes: ["number": "\(index + 1)"])
         
         // Set attributes
         let attributesElement = measureElement.addChild(name: "attributes")
         
         // Calculate divisions
         var divisions = 1
         for notation in measure.notationObjects {
         divisions = max(notation.type.getDivision(), divisions)
         }
         
         // Set divisions
         attributesElement.addChild(name: "divisions", value: "\(divisions)")
         
         // Key signature
         let keyElement = attributesElement.addChild(name: "key")
         keyElement.addChild(name: "fifths", value: "\(measure.keySignature.rawValue)")
         
         // Time signature
         let timeSignatureElement = attributesElement.addChild(name: "time")
         timeSignatureElement.addChild(name: "beats", value: "\(measure.timeSignature.beats)")
         timeSignatureElement.addChild(name: "beat-type", value: "\(measure.timeSignature.beatType)")
         
         // Clef
         let clefElement = attributesElement.addChild(name: "clef")
         clefElement.addChild(name: "sign", value: measure.clef.rawValue)
         clefElement.addChild(name: "line", value: "\(measure.clef.getStandardLine())")
         
         // Add notes and/or rests
         for notation in measure.notationObjects {
         let notationElement = measureElement.addChild(name: "note")
         
         // Add necessary elements depending on note or rest
         if let note = notation as? Note {
         let pitchElement = notationElement.addChild(name: "pitch")
         pitchElement.addChild(name: "step", value: note.pitch.step.toString())
         pitchElement.addChild(name: "octave", value: "\(note.pitch.octave)")
         } else if notation is Rest {
         notationElement.addChild(name: "rest")
         }
         
         // Set duration and type
         notationElement.addChild(name: "duration", value: "\(notation.type.getDuration(divisions: divisions))")
         notationElement.addChild(name: "type", value: notation.type.toString())
         }
         }*/
        
        // Get string format of xml
        var xmlString = xml.xml
        
        // Add MusicXML Declaration
        let doctype =
        """
        
        <!DOCTYPE score-partwise PUBLIC
            "-//Recordare//DTD MusicXML 3.1 Partwise//EN"
            "http://www.musicxml.org/dtds/partwise.dtd">
        """
        var index = xmlString.index(of: ">")!
        index = xmlString.index(index, offsetBy: 1, limitedBy: xmlString.endIndex)!
        xmlString.insert(contentsOf: doctype, at: index)
        
        print(xmlString)
        
        return xmlString
    }
    
    static func musicXMLtoComposition(_ xml: String) -> Composition {
        let composition = Composition()
        
        // Perform conversion here
        do {
            let xml = try AEXMLDocument(xml: xml)
            
            let measureElements = xml.root["part"].children
            
            let gStaff = Staff()
            let fStaff = Staff()
            
            for measureElement in measureElements {
                // Get attributes
                let keySignature = KeySignature(rawValue: Int(measureElement["attributes"]["key"]["fifths"].string)!)
                let timeSignature = TimeSignature(beats: Int(measureElement["attributes"]["time"]["beats"].string)!,
                                                  beatType: Int(measureElement["attributes"]["time"]["beat-type"].string)!)
                let clef = Clef(rawValue: measureElement["attributes"]["clef"]["sign"].string)
                
                let measure = Measure(keySignature: keySignature!,
                                      timeSignature: timeSignature,
                                      clef: clef!)
                //                print(measure.keySignature.toString())
                //                print("beats: \(measure.timeSignature.beats)")
                //                print(measure.clef.rawValue)
                
                // Get notes and/or rests
                if let notationElements = measureElement["note"].all {
                    for notationElement in notationElements {
                        //let notation = MusicNotation(type: RestNoteType.convert(notationElement["type"].string))
                        let type = RestNoteType.convert(notationElement["type"].string)
                        
                        if let step = notationElement["pitch"]["step"].value {
                            let pitch = Pitch(step: Step.convert(step),
                                              octave: Int(notationElement["pitch"]["octave"].string)!)
                            let note = Note(pitch: pitch, type: type)
                            
                            //                            print(note.pitch.step.toString())
                            //                            print("\(note.pitch.octave)")
                            //measure.notationObjects.append(note)
                            
                            measure.addToMeasure(note)
                        } else {
                            let rest = Rest(type: type)
                            //measure.notationObjects.append(rest)
                            
                            measure.addToMeasure(rest)
                        }
                    }
                }
                
                if measure.clef == .G {
                    gStaff.addMeasure(measure)
                } else if measure.clef == .F {
                    fStaff.addMeasure(measure)
                }
                
                composition.addStaff(gStaff)
                composition.addStaff(fStaff)
            }
            
        } catch {
            print("\(error)")
        }
        
        return composition
    }
}
