//
//  Bin.swift
//  Assignment3
//
//  Created by NISUM on 6/19/17.
//  Copyright © 2017 Nisum Macbook. All rights reserved.
//

import Foundation

class Bin:EntityBase {
    var location:Location?
    
    convenience init(name:String, location:Location)   {
        self.init(name:name)
        self.location = location
    }
    
    init(name:String)   {
        super.init(name:name, entityTypeName:String(describing:type(of:self)))
    }
}
