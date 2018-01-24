//
// Created by Kevin Chan on 24/01/2018.
// Copyright (c) 2018 MusicG. All rights reserved.
//

import Foundation

extension Date {

    func toString(withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let myString = formatter.string(from: self)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = format

        return formatter.string(from: yourDate!)
    }
}