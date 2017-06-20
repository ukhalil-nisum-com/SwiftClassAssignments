//
//  EntityBase.swift
//  Assignment3
//
//  Created by NISUM on 6/19/17.
//  Copyright © 2017 Nisum Macbook. All rights reserved.
//

import Foundation

enum EntityType {
    case Bin
    case Item
    case Location
}

class EntityBase    {
    var name:String?
    var entityType:EntityType?
    
    init(name:String, entityTypeName:String)    {
        self.name = name
        self.entityType = EntityBase.getEntityType(fromString:entityTypeName)
    }
    
    init(name:String, entityType:EntityType)   {
        self.name = name
        self.entityType = entityType
    }
    
    static func getEntityType(fromString:String) -> EntityType? {
        var entityType:EntityType?
        switch (fromString) {
        case String(describing:EntityType.Bin):
            entityType = EntityType.Bin
        case String(describing:EntityType.Item):
            entityType = EntityType.Item
        case String(describing:EntityType.Location):
            entityType = EntityType.Location
        default: break
        }
        return entityType
    }
    
    //Doesn't work because self is not available until after init is complete
    //    func getEntityType(fromObject:EntityBase) -> EntityType? {
    //        return EntityBase.getEntityType(fromString: String(describing:type(of:self)))
    //    }
}
