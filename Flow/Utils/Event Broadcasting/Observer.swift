//
//  ObserverFunction.swift
//  Flow
//
//  Created by Kevin Chan on 09/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

// Class that encloses the function
class Observer {
    let id: String
    let functionWithParams: ((Parameters) -> Void)?
    let functionWithNoParams: (() -> Void)?
    
    init(id: String, function: @escaping (Parameters) -> Void) {
        self.id = id
        self.functionWithParams = function
        self.functionWithNoParams = nil
    }
    
    init(id: String, function: @escaping () -> Void) {
        self.id = id
        self.functionWithNoParams = function
        self.functionWithParams = nil
    }
    
    static func == (lhs: Observer, rhs: Observer) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func != (lhs: Observer, rhs: Observer) -> Bool {
        return lhs.id != rhs.id
    }
    
    func execute() {
        if self.functionWithNoParams != nil {
            self.functionWithNoParams!()
        }
    }
    
    func execute(_ params: Parameters) {
        if self.functionWithParams != nil {
            self.functionWithParams!(params)
        }
    }
}
