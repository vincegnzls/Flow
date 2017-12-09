//
//  EventBroadcaster.swift
//  Flow
//
//  Created by Kevin Chan on 09/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class EventBroadcaster {
    
    // MARK: Shared instance
    static let instance = EventBroadcaster()
    
    // MARK: Properties
    private let eventObservers: [String: ObserverList]
    
    private init() {
        self.eventObservers = [:]
    }
}
