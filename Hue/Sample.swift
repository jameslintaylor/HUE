//
//  HUE.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import Foundation
import CoreData

class Sample: NSManagedObject {
    
    @NSManaged var blue: NSNumber
    @NSManaged var green: NSNumber
    @NSManaged var order: NSNumber
    @NSManaged var red: NSNumber
    @NSManaged var thumbnail: NSManagedObject
    
}