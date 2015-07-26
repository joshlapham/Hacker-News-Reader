//
//  TopStoriesViewController.swift
//  Hacker News Reader
//
//  Created by Josh Lapham on 26/07/2015.
//  Copyright © 2015 Nerd Burger Labs. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Constants
// HN API keys
let kApiKeyId = "id"
let kApiKeyPosition = "position"
let kApiKeyTypeStory = "story"

// MARK: - TopStoriesViewController class
class TopStoriesViewController: UITableViewController {
    // MARK: Properties
    
    // MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Top Stories"
        
        self.fetchTopStoryIDs()
    }
}

// MARK: - Helper methods extension
extension TopStoriesViewController {
    // MARK: Methods
    // Fetch data for view
    func fetchDataForView() {
        // TODO: implement
    }
    
    // Fetch top story IDs
    func fetchTopStoryIDs() {
        self.fetchTopStoryIDsSignal().subscribeNext({ (topItems: AnyObject?) -> Void in
            //            print(topItems)
            }) { () -> Void in
                print("Finished fetching top story IDs")
        }
    }
}

// MARK: - ReactiveCocoa helper methods extension
extension TopStoriesViewController {
    // MARK: Methods
    func fetchTopStoryIDsSignal() -> RACSignal {
        let scheduler = RACScheduler(priority: RACSchedulerPriorityBackground)
        
        return RACSignal.startLazilyWithScheduler(scheduler, block: { (subscriber: RACSubscriber!) -> Void in
            // Number of items to fetch
            let itemCountToFetch = 100
            
            // Init API URL
            let hackerNewsAPIURL = "https://hacker-news.firebaseio.com/v0/topstories"
            
            // Init Firebase
            let firebaseRef = Firebase(url: hackerNewsAPIURL)
            
            // Fetch data
            firebaseRef.observeSingleEventOfType(FEventType.Value) { (snapshot: FDataSnapshot!) -> Void in
                // Init topItems array
                var topItems = NSMutableArray.new()
                
                // Loop over received data to get top story IDs
                let enumerator = snapshot.children
                
                while let childSnap: FDataSnapshot = enumerator.nextObject() as! FDataSnapshot! {
                    // Only fetch itemsCountToFetch
                    if topItems.count == itemCountToFetch {
                        break
                    }
                    
                    // Item position in top 100
                    let topItemPosition = childSnap.name
                    
                    // Item ID
                    let topItemId = childSnap.value
                    
                    // Init item dict
                    let itemDict = [kApiKeyPosition : topItemPosition, kApiKeyId : topItemId]
                    
                    // Add dict to topItems array
                    topItems.addObject(itemDict)
                }
                
                subscriber.sendNext(topItems)
                subscriber.sendCompleted()
            }
        })
    }
}