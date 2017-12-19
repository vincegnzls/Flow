//
//  ParserWriter.swift
//  Flow
//
//  Created by Kevin Chan on 04/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

// Singleton class for handling files
class FileHandler {
    
    // MARK: Constants
    private static let KEY_COMPOSITION_LIST: String = "composition_list"
    private let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                                  appropriateFor: nil, create: true) // For file handling
    
    // MARK: Shared instance
    static let instance = FileHandler()
    
    // MARK: Properties
    var compositions: [CompositionInfo]
    
    private init() {
        compositions = []
        retrieveCompositionList()
    }
    
    // MARK: File handling functions
    func readFile(_ compositionInfo: CompositionInfo) -> Composition {
        let fileURL = documentsDirectory.appendingPathComponent(compositionInfo.id).appendingPathExtension("xml")
        var readString = ""
        
        do {
            readString = try String(contentsOf: fileURL)
        } catch let error as NSError {
            print("Failed to read file \(compositionInfo.name) with id \(compositionInfo.id)")
            print(error)
        }
        
        let composition = convertMusicXMLtoComposition(readString)
        composition.compositionInfo = compositionInfo
        return composition
    }
    
    func saveFile(composition: Composition) {
        let fileURL = documentsDirectory.appendingPathComponent(composition.compositionInfo.id).appendingPathExtension("xml")
        
        let writeString = convertCompositionToMusicXML(composition)
        do {
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed to write to file \(composition.compositionInfo.name) with id \(composition.compositionInfo.id)")
            print(error)
        }
    }
    
    // MARK: Conversion functions
    func convertCompositionToMusicXML(_ composition: Composition) -> String {
        let xml = AEXMLDocument()
        
        let score = xml.addChild(name: "score-partwise", attributes: ["version": "3.1"])
        let partList = score.addChild(name: "part-list")
        let scorePart = partList.addChild(name: "score-part", attributes: ["id": "P1"])
        scorePart.addChild(name: "part-name", value: "Music")
        
        score.addChild(name: "part", attributes: ["id": "P1"])
        // loop through measures
        
        return xml.xml
    }
    
    func convertMusicXMLtoComposition(_ xml: String) -> Composition {
        // Perform conversion here
        
        return Composition()
    }
    
    private func retrieveCompositionList() {
        if let objects = UserDefaults.standard.value(forKey: FileHandler.KEY_COMPOSITION_LIST) as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [CompositionInfo] {
                compositions = objectsDecoded
            }
        }
    }
    
    func saveCompositionList() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(compositions){
            UserDefaults.standard.set(encoded, forKey: FileHandler.KEY_COMPOSITION_LIST)
        }
    }
}
