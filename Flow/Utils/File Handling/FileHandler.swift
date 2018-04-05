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
        
        let composition = Converter.musicXMLtoComposition(readString)
        composition.compositionInfo = compositionInfo
        return composition
    }
    
    func saveFile(composition: Composition) -> Bool {
        let fileURL = documentsDirectory.appendingPathComponent(composition.compositionInfo.id).appendingPathExtension("xml")
        
        let writeString = Converter.compositionToMusicXML(composition)
        do {
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            
            if !self.compositions.contains(composition.compositionInfo) {
                self.compositions.append(composition.compositionInfo)
            } else {
                let index = self.compositions.index(of: composition.compositionInfo)!
                composition.compositionInfo.lastEdited = Date()
                self.compositions[index] = composition.compositionInfo
            }
            
            self.saveCompositionList()
            
        } catch let error as NSError {
            print("Failed to write to file \(composition.compositionInfo.name) with id \(composition.compositionInfo.id)")
            print(error)
            return false
        }
        
        return true
    }
    
    func export(_ compositionInfo: CompositionInfo) -> URL? {
        // 4
        guard let _ = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
        }
        
        // 5
        let fileURL = documentsDirectory.appendingPathComponent(compositionInfo.id).appendingPathExtension("xml")
        return fileURL
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
            print("saved composition list")
        }
    }

    func deleteComposition(at index: Int) {
        let infoToDelete = self.compositions.remove(at: index)

        // Get file url
        let fileURL = documentsDirectory.appendingPathComponent(infoToDelete.id).appendingPathExtension("xml")

        // delete composition
        do {
            try FileManager.default.removeItem(at: fileURL)
            self.saveCompositionList()
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
    }
}
