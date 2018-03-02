//
//  File.swift
//  Flow
//
//  Created by Kevin Chan on 09/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class Parameters {
    
    private var intData: [String: Int]
    private var floatData: [String: Float]
    private var doubleData: [String: Double]
    private var boolData: [String: Bool]
    private var stringData: [String: String]
    private var anyData: [String: Any]
    
    init() {
        self.intData = [:]
        self.floatData = [:]
        self.doubleData = [:]
        self.boolData = [:]
        self.stringData = [:]
        self.anyData = [:]
    }
    
    // MARK: Put Methods
    func put(key: String, value: Int) {
        self.intData.updateValue(value, forKey: key)
    }
    
    func put(key: String, value: Float) {
        self.floatData.updateValue(value, forKey: key)
    }
    
    func put(key: String, value: Double) {
        self.doubleData.updateValue(value, forKey: key)
    }
    
    func put(key: String, value: Bool) {
        self.boolData.updateValue(value, forKey: key)
    }
    
    func put(key: String, value: String) {
        self.stringData.updateValue(value, forKey: key)
    }
    
    func put(key: String, value: Any) {
        self.anyData.updateValue(value, forKey: key)
    }
    
    // MARK: Get Methods
    func get(key: String, defaultValue: Int) -> Int {
        if let val = self.intData[key] {
            return val
        } else {
            return defaultValue
        }
    }
    
    func get(key: String, defaultValue: Float) -> Float {
        if let val = self.floatData[key] {
            return val
        } else {
            return defaultValue
        }
    }
    
    func get(key: String, defaultValue: Double) -> Double {
        if let val = self.doubleData[key] {
            return val
        } else {
            return defaultValue
        }
    }
    
    func get(key: String, defaultValue: Bool) -> Bool {
        if let val = self.boolData[key] {
            return val
        } else {
            return defaultValue
        }
    }
    
    func get(key: String, defaultValue: String) -> String {
        if let val = self.stringData[key] {
            return val
        } else {
            return defaultValue
        }
    }

    func get(key: String) -> Any? {
        if let val = self.anyData[key] {
            return val
        } else {
            return nil
        }
    }
}
