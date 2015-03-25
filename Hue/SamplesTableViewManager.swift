//
//  SamplesTableViewManager.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit
import CoreData

class SamplesTableViewManager: NSObject, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
   
    var tableView: UITableView!
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        var request = NSFetchRequest()
        var entity = NSEntityDescription.entityForName("Sample", inManagedObjectContext: self.managedObjectContext)
        request.entity = entity
        
        var sortDescriptor = NSSortDescriptor(key: "order", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        var fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "ddMMyyyy", cacheName: nil)
        fetchedResultsController.delegate = self
        
        //initial fetch
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        return fetchedResultsController
        
    }()

    // MARK: - Private Methods
    
    func configureCell(cell: SampleTableViewCell, withSample sample: Sample?) {
        
        if sample == nil {
            return
        }
        
        var r = CGFloat(sample!.red)
        var g = CGFloat(sample!.green)
        var b = CGFloat(sample!.blue)
        cell.sampleView.color = UIColor(red: r, green: g, blue: b, alpha: 1)
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: SampleTableViewCell
        if let reusableCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as? SampleTableViewCell {
            cell = reusableCell
        } else {
            cell = SampleTableViewCell(reuseIdentifier: "cell")
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
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SAMPLE_HEIGHT
    }
        
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var headerView = DayHeaderView()
        
        if let ddMMyyyy = self.fetchedResultsController.sections?[section].name {
            
            headerView.ddMMyyyy = ddMMyyyy
            
        }
        
        return headerView
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEADER_HEIGHT
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView?.reloadData()
    }
    
}
