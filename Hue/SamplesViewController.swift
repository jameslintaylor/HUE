//
//  SamplesViewController.swift
//  Hue
//
//  Created by James Taylor on 2015-03-17.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit
import CoreData

class SamplesViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        var request = NSFetchRequest()
        var entity = NSEntityDescription.entityForName("Complate", inManagedObjectContext: self.managedObjectContext)
        request.entity = entity
        
        var sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        var fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        
    }()
    
    // MARK: - Table View Data Source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return UITableViewCell()
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numRows: Int = 0
        
        if let sectionInfo = self.fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo {
            
            numRows = sectionInfo.numberOfObjects
            
        }
        
        return numRows
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var numSections: Int = 0
        
        if let sections = self.fetchedResultsController.sections {
            
            numSections = sections.count
            
        }
        
        return numSections
        
    }
    
}
