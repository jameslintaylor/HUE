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
    
    var tableView: UITableView!
    var managedObjectContext: NSManagedObjectContext!
    
    var selectedRowIndexPath: NSIndexPath? {
        didSet {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    // MARK: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        var request = NSFetchRequest()
        var entity = NSEntityDescription.entityForName("Sample", inManagedObjectContext: self.managedObjectContext)
        request.entity = entity
        
        var sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        var fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "ddMMyyyy", cacheName: nil)
        fetchedResultsController.delegate = self
        
        //initial fetch
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Public Methods
    
    func setEditing(editing: Bool) {
        self.selectedRowIndexPath = nil
        self.tableView.setEditing(editing, animated: true)
    }

    // MARK: - Private Methods
    
    func configureCell(cell: SampleTableViewCell, withSample sample: Sample?) {
        
        if sample == nil {
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
        
        var headerView = DayHeaderView()
        
        if let ddMMyyyy = self.fetchedResultsController.sections?[section].name {
            headerView.ddMMyyyy = ddMMyyyy
        }
        
        return headerView
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEADER_HEIGHT
    }
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var yOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        self.delegate?.tableView(self.tableView, didScrollToYOffset: yOffset)
    }
    
    // MARK: - SampleTableView Delegate
    
    func sampleTableViewCellRequestedDelete(cell: SampleTableViewCell) {
        
        if let sample = cell.sample {
            self.managedObjectContext.deleteObject(sample)
            var error: NSError?
            if !self.managedObjectContext.save(&error) {
                println("save error: \(error?.localizedDescription)")
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
