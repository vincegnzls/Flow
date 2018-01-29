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
    private var items: [MusicNotation]
    
    private init() {
        items = []
    }

    func cut() {

    }

    func copy() {

    }

    func paste() {

    }
}
