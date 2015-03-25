//
//  SamplesTableViewControllerDataSource.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit
import CoreData

class SamplesTableViewControllerDataSource: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
   
    var tableView: UITableView!
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        var request = NSFetchRequest()
        var entity = NSEntityDescription.entityForName("Sample", inManagedObjectContext: self.managedObjectContext)
        request.entity = entity
        
        var sortDescriptor = NSSortDescriptor(key: "order", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        var fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        //initial fetch
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Public Methods
    
    func addSample(color: UIColor?) {
        
        var error: NSError?
        var count = self.managedObjectContext.countForFetchRequest(self.fetchedResultsController.fetchRequest, error: &error)
        
        var newSample = NSEntityDescription.insertNewObjectForEntityForName("Sample", inManagedObjectContext: self.managedObjectContext) as Sample
        newSample.order = count + 1
        
        var rgba = [CGFloat](count: 4, repeatedValue: 0.0)
        color?.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
        newSample.red = rgba[0]
        newSample.green = rgba[1]
        newSample.blue = rgba[2]
        
        var saveError: NSError?
        self.managedObjectContext.save(&saveError)
        if error != nil {
            println("Sample save error: \(error!.localizedDescription)")
        }
        
    }

    // MARK: - Private Methods
    
    func configureCell(cell: UITableViewCell, withSample sample: Sample?) {
        
        if sample == nil {
            return
        }
        
        var r = CGFloat(sample!.red)
        var g = CGFloat(sample!.green)
        var b = CGFloat(sample!.blue)
        cell.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1)
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        if let reusableCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        }
        
        var sample: Sample?
        if let fetchedSample = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Sample {
            sample = fetchedSample
        }
        
        self.configureCell(cell, withSample: sample)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numRows = 0
        
        if let sectionInfo = self.fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo {
            numRows = sectionInfo.numberOfObjects
        }
        
        return numRows
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var numSections = 0
        
        if let sections = self.fetchedResultsController.sections {
            numSections = sections.count
        }
        
        return numSections
        
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.reloadData()
    }
    
}
