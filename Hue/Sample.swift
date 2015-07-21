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
    @NSManaged var red: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var thumbnail: NSManagedObject

    var ddMMyyyy: String {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd:MM:yyyy"
        return dateFormatter.stringFromDate(self.timestamp)
        
    }
    
    var color: UIColor? {
        
        var r = CGFloat(self.red)
        var g = CGFloat(self.green)
        var b = CGFloat(self.blue)
        return UIColor(red: r, green: g, blue: b, alpha: 1)
        
    }
    
    var thumbnailImage: UIImage? {
        
        var ret: UIImage?
        
        if let thumbnail = self.thumbnail as? Thumbnail {
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            let imagePath = paths.stringByAppendingPathComponent(thumbnail.fileName)
            if let imageData = NSData(contentsOfFile: imagePath) {
                ret = UIImage(data: imageData)
            }
            
        }
        
        return ret
        
    }
    
    deinit {
        println("Sample deinitialized")
    }
    
    // MARK: Public Methods
    
    class func insertSampleWithColor(color: UIColor?, thumbnail: Thumbnail, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Sample {
        
        var error: NSError?
        
        let sample = NSEntityDescription.insertNewObjectForEntityForName(self.entityName(), inManagedObjectContext: managedObjectContext)as! Sample
        sample.thumbnail = thumbnail
        sample.timestamp = NSDate()
        
        var rgba = [CGFloat](count: 4, repeatedValue: 0.0)
        color?.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
        sample.red = rgba[0]
        sample.green = rgba[1]
        sample.blue = rgba[2]
        
        var saveError: NSError?
        managedObjectContext.save(&saveError)
        if saveError != nil {
            println("Sample save error: \(saveError!.localizedDescription)")
        }
        
        return sample
    }
    
    class func entityName() -> String {
        return "Sample"
    }
    
}
