//
//  TopStoriesDataSource.swift
//  Hacker News Reader
//
//  Created by Josh Lapham on 26/07/2015.
//  Copyright © 2015 Nerd Burger Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - Constants
let cellIdentifer = "TopStoryCell"

// MARK: - TopStoriesDataSource class
class TopStoriesDataSource: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource {
    // MARK: Properties
    var cellDataSource: NSArray!
    
    // MARK: Methods
    override init() {
        super.init()
        
        self.cellDataSource = NSArray.new()
    }
}

// MARK: - UITableViewDataSource delegate methods
extension TopStoriesDataSource {
    // MARK: Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifer, forIndexPath: indexPath) as UITableViewCell
        
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate methods extension
extension TopStoriesDataSource {
    // MARK: Methods
}