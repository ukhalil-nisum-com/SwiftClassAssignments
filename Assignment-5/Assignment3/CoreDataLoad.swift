//
//  CoreDataLoad.swift
//  Assignment3
//
//  Created by NISUM on 7/6/17.
//  Copyright © 2017 Nisum Macbook. All rights reserved.
//

import CoreData
import UIKit
import Foundation

class CoreDataLoad {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var coreDataFetch:CoreDataFetch = CoreDataFetch()
    
    init(context:NSManagedObjectContext)    {
        self.context = context
        self.coreDataFetch = CoreDataFetch(context: context)
    }
    
    func loadItem(fromJSON:Dictionary<String, Any>) -> Item {
        var item:Item? = coreDataFetch.fetchEntity(byId: fromJSON["id"] as! NSNumber)
        if item == nil {
            item = Item(context: context)
        }
        item?.setPropertiesFrom(jsonDictionary: fromJSON)
        if let binJSON = fromJSON["bin"] as? Dictionary<String, Any> {
            let bin = loadBin(fromJSON: binJSON)
            item?.itemToBinFK = bin
        }
        self.saveContext()
        return item!
    }
    
    func loadBin(fromJSON:Dictionary<String, Any>) -> Bin  {
        var bin:Bin? = coreDataFetch.fetchEntity(byId: fromJSON["id"] as! NSNumber)
        if bin == nil {
            bin = Bin(context: context)
        }
        bin?.setPropertiesFrom(jsonDictionary: fromJSON)
        if let locationJSON = fromJSON["location"] as? Dictionary<String, Any> {
            let location = loadLocation(fromJSON: locationJSON)
            bin?.binToLocationFK = location
        }
        self.saveContext()
        return bin!
    }
    
    func loadLocation(fromJSON:Dictionary<String, Any>) -> Location  {
        var location:Location? = coreDataFetch.fetchEntity(byId: fromJSON["id"] as! NSNumber)
        if location == nil {
            location = Location(context: context)
        }
        location?.setPropertiesFrom(jsonDictionary: fromJSON)
        self.saveContext()
        return location!
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
