//
//  ObserverList.swift
//  Flow
//
//  Created by Kevin Chan on 09/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class ObserverList {
//    private var observersWithParams: [(Parameters)]
//    private var observersWithNoParams: [()]
//
//    init() {
//        self.observersWithParams = []
//        self.observersWithNoParams = []
//    }
//
//    func addObserver(_ action: (Parameters)) {
//        self.observersWithParams.append(action)
//    }
//
//    func addObserver(_ action: ()) {
//        self.observersWithNoParams.append(action)
//    }
//
//    func removeObserver(_ action: (Parameters)) {
//        self.observersWithParams = self.observersWithParams.filter() {$0 !== action}
//    }
//
//    func removeObserver(_ action: ()) {
//        self.observersWithNoParams = self.observersWithNoParams.filter() {$0 != action}
//    }
    
    private var observers: [Observer]
    
    init() {
        self.observers = []
    }
    
    func addObserver(_ function: Observer) {
        if !self.observers.contains(where: { observer in observer.id == function.id}) {
            self.observers.append(function)
        }
    }
    
    func removeObserver(_ function: Observer) {
        self.observers = self.observers.filter() {$0 != function}
    }
    
    func clearObservers() {
        self.observers.removeAll()
    }
    
    func notifyObservers() {
        for observer in observers {
            observer.execute()
        }
    }
    
    func notifyObservers(_ params: Parameters) {
        for observer in observers {
            observer.execute(params)
        }
    }
}
