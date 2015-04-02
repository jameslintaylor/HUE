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

    @NSManaged var fileName: String
    @NSManaged var sample: Sample

    class func insertThumbnailWithFileName(fileName: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Thumbnail {

        let thumbnail = NSEntityDescription.insertNewObjectForEntityForName(self.entityName(), inManagedObjectContext: managedObjectContext) as Thumbnail

        thumbnail.fileName = fileName
        
        var saveError: NSError?
        managedObjectContext.save(&saveError)
        if saveError != nil {
            println("Sample save error: \(saveError!.localizedDescription)")
        }
        
        return thumbnail

    }
    
    class func entityName() -> String {
        return "Thumbnail"
    }
}
