//
//  SamplesTableViewManager.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit
import CoreData

protocol SamplesTableViewManagerDelegate: class {
    func tableView(tableView: UITableView, didScrollToYOffset yOffset: CGFloat)
    func tableView(tableView: UITableView, displayingNoData noData: Bool)
}

class SamplesTableViewManager: NSObject, UITableViewDataSource, UITableViewDelegate, SampleTableViewCellDelegate, NSFetchedResultsControllerDelegate {
   
    weak var delegate: SamplesTableViewManagerDelegate?
    
    // TODO: Not sure why I need a reference to table view, surely this could be hidden. Also these are all a bit ugly.
    var tableView: UITableView!
    var managedObjectContext: NSManagedObjectContext!
    var selectedRowIndexPath: NSIndexPath? {
        didSet {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    /**
     **Singleton style date formatter with a dd/MM/yyyy date format.**
     
     Creating date formatters is a relatively expensive operation.
     As of iOS 7.0, `NSDateFormatter` is thread safe so this should be fine.
     */
    static let sectionDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    // Fetched results controller
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        // Configure the request
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Sample", inManagedObjectContext: self.managedObjectContext)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        // Configure the controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "ddmmyyyy", cacheName: nil)
        fetchedResultsController.delegate = self
        
        // Perform initial fetch
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch results with error: \(error)")
        }
        
        return fetchedResultsController
    }()
    
    // MARK: - Public Methods
    
    func setEditing(editing: Bool) {
        self.selectedRowIndexPath = nil
        self.tableView.setEditing(editing, animated: true)
    }

    // MARK: - Private Methods
    
    private func configureCell(cell: SampleTableViewCell, withSample sample: Sample?) {
        guard let sample = sample else {
            return
        }
        
        cell.sample = sample
        cell.delegate = self
        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: SampleTableViewCell
        if let reusableCell = tableView.dequeueReusableCellWithIdentifier("cell") as? SampleTableViewCell {
            cell = reusableCell
        } else {
            cell = SampleTableViewCell(reuseIdentifier: "cell")
            
            // Configure an editing control
            let deleteControl = CellDeleteControl()
            cell.accessoryView = deleteControl
        }
        
        var sample: Sample?
        if let fetchedSample = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Sample {
            sample = fetchedSample
        }
        
        self.configureCell(cell, withSample: sample)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var numSections = 0
        
        if let sections = self.fetchedResultsController.sections {
            numSections = sections.count
        }
        
        self.delegate?.tableView(self.tableView, displayingNoData: numSections == 0)
        
        return numSections
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: - UITableView Delegate
   
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if indexPath == self.selectedRowIndexPath {
            self.selectedRowIndexPath = nil
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
            return nil
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRowIndexPath = indexPath
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight = SAMPLE_HEIGHT
            
        if indexPath == self.selectedRowIndexPath {
            rowHeight = SAMPLE_HEIGHT * 2
        }
        
        return rowHeight
    }
        
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = DayHeader()
        
        guard let
            ddmmyyyy = self.fetchedResultsController.sections?[section].name,
            date = SamplesTableViewManager.sectionDateFormatter.dateFromString(ddmmyyyy)
        else {
            return header
        }
        
        header.date = date
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEADER_HEIGHT
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        self.delegate?.tableView(self.tableView, didScrollToYOffset: yOffset)
    }
    
    // MARK: - SampleTableView Delegate
    
    func sampleTableViewCellRequestedDelete(cell: SampleTableViewCell) {
        
        if let sample = cell.sample {
            self.managedObjectContext.deleteObject(sample)
            var error: NSError?
            do {
                try self.managedObjectContext.save()
            } catch let error1 as NSError {
                error = error1
                print("save error: \(error?.localizedDescription)")
            }
        }
        
    }
    
    // MARK: - NSFetchedResultsController Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            if let newIndexPath = newIndexPath {
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
            }
            
        case .Delete:
            if let indexPath = indexPath {
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            }
            
        default:
            break
            
        }
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        default:
            break
            
        }
        
    }
    
}
