//
//  SamplesViewController.swift
//  Hue
//
//  Created by James Taylor on 2015-03-17.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class SamplesViewController: UIViewController {
    
    let tableViewManager = SamplesTableViewManager()
    
    var tableView: UITableView!
    
    override func loadView() {
        
        var rootView = UIView()
        
        self.tableView = UITableView()
        self.tableView.contentInset = UIEdgeInsets(top: SAMPLE_HEIGHT, left: 0, bottom: 0, right: 0)
        self.tableView.backgroundColor = UIColor.blackColor()
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.tableView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        
        rootView.addSubview(self.tableView)
        
        self.view = rootView
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableViewManager.tableView = self.tableView
        self.tableView.dataSource = self.tableViewManager
        self.tableView.delegate = self.tableViewManager
        
    }
    
}
