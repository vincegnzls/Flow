//
//  KeySignatureData.swift
//  Flow
//
//  Created by Vince on 18/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation

class KeySignatureData {

    var data = [KeySignatureModel]()
    
    class func getData() -> [KeySignatureModel] {
        var data  = [KeySignatureModel]()
        
        data.append(KeySignatureModel(key: KeySignature.c))
        data.append(KeySignatureModel(key: KeySignature.f))
        data.append(KeySignatureModel(key: KeySignature.bFlat))
        data.append(KeySignatureModel(key: KeySignature.eFlat))
        data.append(KeySignatureModel(key: KeySignature.aFlat))
        data.append(KeySignatureModel(key: KeySignature.dFlat))
        data.append(KeySignatureModel(key: KeySignature.gFlat))
        data.append(KeySignatureModel(key: KeySignature.cFlat))
        data.append(KeySignatureModel(key: KeySignature.g))
        data.append(KeySignatureModel(key: KeySignature.d))
        data.append(KeySignatureModel(key: KeySignature.a))
        data.append(KeySignatureModel(key: KeySignature.e))
        data.append(KeySignatureModel(key: KeySignature.b))
        data.append(KeySignatureModel(key: KeySignature.fSharp))
        data.append(KeySignatureModel(key: KeySignature.cSharp))
        
        return data
    }

    class func getIndexOf(ks: KeySignature) -> Int {
        var index = 0

        for x in KeySignatureData.getData() {
            if x.key == ks {
                return index
            }

            index = index + 1
        }

        return -1

    }
}
