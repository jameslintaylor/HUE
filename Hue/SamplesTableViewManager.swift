//
//  SamplesTableViewManager.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit
import CoreData

// TODO: These don't really need to be here. It's just abusing the delegation pattern.
protocol SamplesTableViewManagerDelegate: class {
    func tableView(tableView: UITableView, didScrollToYOffset yOffset: CGFloat)
    func tableView(tableView: UITableView, displayingNoData noData: Bool)
}

class SamplesTableViewManager: NSObject, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    weak var delegate: SamplesTableViewManagerDelegate?
    weak var tableView: UITableView?
    
    // TODO: No implictly unwrapped optionals please.
    var managedObjectContext: NSManagedObjectContext!
    
    /**
     Singleton style date formatter with a dd/MM/yyyy date format.
     
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

    // MARK: - Private methods
    
    // TODO: Can probably rename this method to be a bit less ambiguous.
    /**
     Attempts to delete the sample object at the given NSFetchedResultsController's index path from the persistent store.
    
     - returns: Boolean indicating if the delete was succesful.
     */
    private func deleteSampleAtIndexPath(indexPath: NSIndexPath) -> Bool {
        guard let sample = fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject else {
            return false
        }
        
        do {
            managedObjectContext.deleteObject(sample)
            try managedObjectContext.save()
        } catch {
            return false
        }
        
        return true
    }
    
    /**
     Assigns a new `Sample` object to a `SamplesTableViewCell` and configures the cell for the new sample.
     */
    private func configureCell(cell: SamplesTableViewCell, withSample sample: Sample) {
        cell.sample = sample
        
        // Configure the cell for the new sample
        cell.selectionStyle = .Gray
        cell.backgroundColor = sample.color
        cell.tintColor = sample.color?.darkerColor()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        
        // TODO: Change this
        delegate?.tableView(tableView, displayingNoData: sections.count == 0)
        
        return sections.count
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteSampleAtIndexPath(indexPath)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // Configure the delete action
        let deleteAction = UITableViewRowAction(style: .Destructive, title: "Delete", handler: { (action, indexPath) in
            self.deleteSampleAtIndexPath(indexPath)
        })
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        print("will select row \(indexPath.row) in section \(indexPath.section)")
        if tableView.indexPathsForSelectedRows?.contains(indexPath) == true {
            // Deselect already selected cell
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            return nil
        }
        
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("did select row \(indexPath.row) in section \(indexPath.section)")
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        print("will deselect row \(indexPath.row) in section \(indexPath.section)")
        return indexPath
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        print("did deselect row \(indexPath.row) in section \(indexPath.section)")
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SamplesTableViewCell
        
        if let reusableCell = tableView.dequeueReusableCellWithIdentifier("cell") as? SamplesTableViewCell {
            cell = reusableCell
        } else {
            cell = SamplesTableViewCell(reuseIdentifier: "cell")
        }
        
        guard let sample = fetchedResultsController.objectAtIndexPath(indexPath) as? Sample else {
            return cell
        }
        
        configureCell(cell, withSample: sample)
        return cell
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
    
    /*
    From the docs: 
        Providing a nonnegative estimate of the height of rows can improve the performance of loading the table view. 
        If the table contains variable height rows, it might be expensive to calculate all their heights when the table loads.
        Using estimation allows you to defer some of the cost of geometry calculation from load time to scrolling time.
    
    Although (on loading) all the rows in this tableview should have the same height, this is implemented for completeness.
    */
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    /* 
    Although UITableView.rowHeight is typically used in the scenario where the table view's delegate has not
    implemented `tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat`, 
    it's used within the implementation here to provide the larger selected height behaviour for cells.
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Selected row should have double the height.
        return tableView.indexPathsForSelectedRows?.contains(indexPath) == true ? tableView.rowHeight*(3/2) : tableView.rowHeight
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.rowHeight/2
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        self.delegate?.tableView(self.tableView!, didScrollToYOffset: yOffset)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView?.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            if let newIndexPath = newIndexPath {
                tableView?.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Left)
            }
        case .Delete:
            if let indexPath = indexPath {
                tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            }
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            break
        }
    }
}
