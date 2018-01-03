//
//  Action.swift
//  Flow
//
//  Created by Kevin Chan on 22/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

protocol Action {
    
    func execute()
    func undo()
    func redo()
}
