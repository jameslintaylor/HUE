//
//  SamplesTableViewControllerDelegate.swift
//  HUE
//
//  Created by James Taylor on 2015-03-24.
//  Copyright (c) 2015 James Lin Taylor. All rights reserved.
//

import UIKit

class SamplesTableViewControllerDelegate: NSObject, UITableViewDelegate {
   
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SWATCH_HEIGHT
    }
    
}
