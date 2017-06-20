//
//  Location.swift
//  Assignment3
//
//  Created by NISUM on 6/19/17.
//  Copyright © 2017 Nisum Macbook. All rights reserved.
//

import Foundation

class Location:EntityBase {
    init(name:String)   {
        super.init(name:name, entityTypeName:String(describing:type(of:self)))
    }
}
