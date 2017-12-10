//
//  TestClass.swift
//  Flow
//
//  Created by Kevin Chan on 10/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class TestClass {
    
    init() {
        EventBroadcaster.instance.addObserver(event: EventNames.ARROW_KEY_PRESSED,
                                              observer: Observer(id: "TestClass.testFunc", function: self.testFunc))
    }
    
    func testFunc(params: Parameters) {
        let val = params.get(key: KeyNames.ARROW_KEY_DIRECTION) // Used for objects
        let val2 = params.get(key: KeyNames.ARROW_KEY_DIRECTION, defaultValue: 5) // Primitive data types have default value
    }
}
