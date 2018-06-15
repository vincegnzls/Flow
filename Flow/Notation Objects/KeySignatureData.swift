//
//  KeySignatureData.swift
//  Flow
//
//  Created by Vince on 18/12/2017.
//  Copyright © 2017 MusicG. All rights reserved.
//

import Foundation
import UIKit

class KeySignatureData {

    var data = [KeySignatureModel]()
    
    class func getData() -> [KeySignatureModel] {
        var data  = [KeySignatureModel]()

        data.append(KeySignatureModel(key: KeySignature.c, image: nil))
        data.append(KeySignatureModel(key: KeySignature.g, image: UIImage(named: "keysig-g")))
        data.append(KeySignatureModel(key: KeySignature.d, image: UIImage(named: "keysig-d")))
        data.append(KeySignatureModel(key: KeySignature.a, image: UIImage(named: "keysig-a")))
        data.append(KeySignatureModel(key: KeySignature.e, image: UIImage(named: "keysig-e")))
        data.append(KeySignatureModel(key: KeySignature.b, image: UIImage(named: "keysig-b")))
        data.append(KeySignatureModel(key: KeySignature.fSharp, image: UIImage(named: "keysig-fsharp")))
        data.append(KeySignatureModel(key: KeySignature.cSharp, image: UIImage(named: "keysig-csharp")))
        data.append(KeySignatureModel(key: KeySignature.cFlat, image: UIImage(named: "keysig-cflat")))
        data.append(KeySignatureModel(key: KeySignature.gFlat, image: UIImage(named: "keysig-gflat")))
        data.append(KeySignatureModel(key: KeySignature.dFlat, image: UIImage(named: "keysig-dflat")))
        data.append(KeySignatureModel(key: KeySignature.aFlat, image: UIImage(named: "keysig-aflat")))
        data.append(KeySignatureModel(key: KeySignature.eFlat, image: UIImage(named: "keysig-eflat")))
        data.append(KeySignatureModel(key: KeySignature.bFlat, image: UIImage(named: "keysig-bflat")))
        data.append(KeySignatureModel(key: KeySignature.f, image: UIImage(named: "keysig-f")))
        
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
