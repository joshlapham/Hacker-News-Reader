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
        // Number of items to fetch
        let itemCountToFetch = 100
        
        // Init API URL
        let hackerNewsAPIURL = "https://hacker-news.firebaseio.com/v0/topstories"
        
        // Init Firebase
        let firebaseRef = Firebase(url: hackerNewsAPIURL)
        
        //            DDLogVerbose(@"%s - fetching top item IDs ..", __func__);
        //
        //            // Number of items to fetch
        //            static NSUInteger itemCountToFetch = 100;
        //
        //            // Init API URL
        //            NSString *hnApiUrl = @"https://hacker-news.firebaseio.com/v0/topstories";
        //
        //            // Init Firebase
        //            Firebase *hnRef = [[Firebase alloc] initWithUrl:hnApiUrl];
        //
        //            // Fetch data
        //            [hnRef observeSingleEventOfType:FEventTypeValue
        //            withBlock:^(FDataSnapshot *snapshot) {
        //            // Init topItems array
        //            NSMutableArray *topItems = [NSMutableArray array];
        //
        //            // Loop over data to get top story IDs
        //            for (FDataSnapshot *childSnap in snapshot.children) {
        //            // Only fetch itemsCountToFetch
        //            if (topItems.count == itemCountToFetch) {
        //            break;
        //            }
        //
        //            // Item position
        //            NSString *topItemPosition = (NSString *)childSnap.name;
        //
        //            // Item ID
        //            NSString *topItemId = [NSString stringWithFormat:@"%@", childSnap.value];
        //
        //            //                                  NSLog(@"%s - ITEM: %@; %@", __func__, topItemPosition, topItemId);
        //
        //            // Init item dict
        //            NSDictionary *itemDict = @{
        //            kApiKeyPosition : topItemPosition,
        //            kApiKeyId : topItemId
        //            };
        //
        //            // Add top story dict to topStories array
        //            [topItems addObject:itemDict];
        //            }
        //            
        //            DDLogVerbose(@"%s - top items count: %lu", __func__, (unsigned long)topItems.count);
        //            
        //            // Pass topItems array to block
        //            block(topItems);
        //            }];
        
        
    }
}