//
//  TopStoriesViewController.swift
//  Hacker News Reader
//
//  Created by Josh Lapham on 26/07/2015.
//  Copyright © 2015 Nerd Burger Labs. All rights reserved.
//

import Foundation
import UIKit

// MARK: - TopStoriesViewController class
class TopStoriesViewController: UITableViewController {
    // MARK: Properties
    
    // MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Top Stories"
    }
}

// MARK: - Helper methods extension
extension TopStoriesViewController {
    // MARK: Methods
    // Fetch data for view
    func fetchDataForView() {
        
    }
    
    // Fetch top story IDs
    func fetchTopStoryIDs() {
        
    }
}