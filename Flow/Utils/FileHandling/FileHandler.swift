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
    var compositions: Array<CompositionInfo>
    
    private init() {
        compositions = Array<CompositionInfo>()
        retrieveCompositionList()
    }
    
    // MARK: File handling functions
    func readFile(_ fileName: String) -> Composition {
        let fileURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("xml")
        var readString = ""
        
        do {
            readString = try String(contentsOf: fileURL)
        } catch let error as NSError {
            print("Failed to read file \(fileName)")
            print(error)
        }
        
        return convertMusicXMLtoComposition(readString)
    }
    
    func writeToFile(composition: Composition, fileName: String) {
        let fileURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("xml")
        
        let writeString = convertCompositionToMusicXML(composition)
        do {
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Failed to write to file \(fileName)")
            print(error)
        }
    }
    
    // MARK: Conversion functions
    func convertCompositionToMusicXML(_ composition: Composition) -> String {
        let xml = AEXMLDocument()
        // Perform conversion here
        
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
