//
//  HUE.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit
import CoreData

class Sample: NSManagedObject {

    @NSManaged var blue: NSNumber
    @NSManaged var green: NSNumber
    @NSManaged var red: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var thumbnail: NSManagedObject
    
    var ddmmyyyy: String {
        get {
            return SamplesTableViewManager.sectionDateFormatter.stringFromDate(timestamp)
        }
    }
    
    var color: UIColor? {
        
        let r = CGFloat(self.red)
        let g = CGFloat(self.green)
        let b = CGFloat(self.blue)
        return UIColor(red: r, green: g, blue: b, alpha: 1)
        
    }
    
    var thumbnailImage: UIImage? {
        var image: UIImage?
        if let thumbnail = thumbnail as? Thumbnail {
            let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let path = "\(documents)/\(thumbnail.filename)"
            if let imageData = NSData(contentsOfFile: path) {
                image = UIImage(data: imageData)
            }
        }
        return image
    }
    
    deinit {
        print("Sample deinitialized")
    }
    
    // MARK: Public Methods
    
    class func insertSampleWithColor(color: UIColor?, thumbnail: Thumbnail, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> Sample {
        
        let sample = NSEntityDescription.insertNewObjectForEntityForName(self.entityName(), inManagedObjectContext: managedObjectContext) as! Sample
        sample.thumbnail = thumbnail
        sample.timestamp = NSDate()
        
        var rgba = [CGFloat](count: 4, repeatedValue: 0.0)
        color?.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
        sample.red = rgba[0]
        sample.green = rgba[1]
        sample.blue = rgba[2]
    
        do {
            try managedObjectContext.save()
        } catch let e {
            print("Sample saving failed: \(e)")
        }
        
        return sample
    }
    
    class func entityName() -> String {
        return "Sample"
    }
    
}
