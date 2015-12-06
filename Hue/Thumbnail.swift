//
//  Thumbnail.swift
//  HUE
//
//  Created by James Taylor on 2015-03-25.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import Foundation
import CoreData

class Thumbnail: NSManagedObject {

    @NSManaged var filename: String
    @NSManaged var sample: Sample

    class func insertThumbnailWithFileName(filename: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Thumbnail {

        let thumbnail = NSEntityDescription.insertNewObjectForEntityForName(self.entityName(), inManagedObjectContext: managedObjectContext) as! Thumbnail

        thumbnail.filename = filename
        
        do {
            try managedObjectContext.save()
        } catch let e {
            print("Sample save failed: \(e)")
        }
        
        return thumbnail

    }
    
    class func entityName() -> String {
        return "Thumbnail"
    }
}
