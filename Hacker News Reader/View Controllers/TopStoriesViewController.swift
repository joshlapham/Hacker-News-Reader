//
//  TopStoriesViewController.swift
//  Hacker News Reader
//
//  Created by Josh Lapham on 26/07/2015.
//  Copyright © 2015 Nerd Burger Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - Constants
// HN API keys
let kApiKeyId = "id"
let kApiKeyPosition = "position"
let kApiKeyTypeStory = "story"

// MARK: - TopStoriesViewController class
class TopStoriesViewController: UITableViewController {
    // MARK: Properties
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Top Stories"
        
        // Setup tableView
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Fetch data for view
        self.fetchDataForView()
    }
}

// MARK: - Helper methods extension
extension TopStoriesViewController {
    // MARK: Methods
    // Fetch data for view
    func fetchDataForView() {
        self.fetchTopStoryIDsSignal().subscribeNext({ (topItems: AnyObject?) -> Void in
            if let topItems = topItems as? [AnyObject] {
                for var itemDict in topItems {
                    // Fetch item
                    self.fetchStory(itemDict[kApiKeyId] as! NSNumber)
                }
            }
            
            }) { () -> Void in
                print("Finished fetching top story IDs")
        }
    }
}

// MARK: - Firebase HN API keys struct
struct FirebaseAPIKey {
    static let storyId = "id"
    static let isDeleted = "deleted"
    static let storyType = "type"
    static let storyAuthor = "by"
    static let storyTime = "time"
    static let storyText = "text"
    static let deadOrNot = "dead"
    static let storyParentId = "parent"
    static let storyChildIds = "kids"
    static let storyUrl = "url"
    static let storyScore = "score"
    static let storyTitle = "title"
    static let storyPollIds = "parts"
}

// MARK: - ReactiveCocoa helper methods extension
extension TopStoriesViewController {
    // MARK: Methods
    // Fetch story with story ID method
    func fetchStory(storyId: NSNumber) {
        // Init API URL
        let apiCallUrl = NSString(format: "https://hacker-news.firebaseio.com/v0/item/%@", storyId.stringValue) as String
        
        // Init Firebase ref
        let hnRef = Firebase(url: apiCallUrl)
        
        // Fetch
        hnRef.observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
            // Init vars for returned API results
            let storyId = snapshot.value[FirebaseAPIKey.storyId] as! NSNumber
            let storyType = snapshot.value[FirebaseAPIKey.storyType] as! String
            let storyAuthor = snapshot.value[FirebaseAPIKey.storyAuthor] as! String
            let storyUrl = snapshot.value[FirebaseAPIKey.storyUrl] as? String
            let storyTitle = snapshot.value[FirebaseAPIKey.storyTitle] as! String
            
            // TODO: fix commented properties
            //            BOOL isDeleted = (BOOL)snapshot.value[@"deleted"];
            //            let isDeleted = snapshot.value[FirebaseAPIKey.isDeleted] as! Bool
            
            //            let storyTime = snapshot.value[FirebaseAPIKey.storyTime] as! NSNumber
            //            NSNumber *storyTime = snapshot.value[@"time"];
            
            //            let deadOrNot = snapshot.value[FirebaseAPIKey.deadOrNot] as! Bool
            //            BOOL deadOrNot = (BOOL)snapshot.value[@"dead"];
            
            //            let storyParentId = snapshot.value[FirebaseAPIKey.storyParentId] as! NSNumber
            //            NSNumber *storyParentId = snapshot.value[@"parent"];
            
            //            NSString *storyText = snapshot.value[@"text"];
            //            NSArray *storyChildIds = [[NSArray alloc] initWithArray:snapshot.value[@"kids"]];
            //            NSArray *storyPollIds = [NSArray arrayWithArray:snapshot.value[@"parts"]];
            //            NSNumber *storyScore = snapshot.value[@"score"];
            
            // Init HNRItem
            // TODO: init in private managed object context
            var item = NSEntityDescription.insertNewObjectForEntityForName("HNRItem", inManagedObjectContext: self.managedObjectContext) as! HNRItem
            
            // Set properties
            item.itemId = storyId
            // TODO: fix commented properties
            //            item.itemIsDeleted = isDeleted
            item.itemType = storyType
            item.author = storyAuthor
            //                item.date = storyTime
            //            item.isDead = NSNumber(bool: deadOrNot)
            //            item.parentId = storyParentId
            item.url = storyUrl
            item.title = storyTitle
            
            print(item)
        })
        
        //            // Set details
        //            item.itemId = storyId;
        //            item.itemIsDeleted = [NSNumber numberWithBool:isDeleted];
        //            item.itemType = storyType;
        //            item.author = storyAuthor;
        //            item.date = [NSDate dateWithTimeIntervalSince1970:[storyTime doubleValue]];
        //            item.text = storyText;
        //            item.isDead = [NSNumber numberWithBool:deadOrNot];
        //            item.parentId = storyParentId;
        //            item.childIds = storyChildIds;
        //            item.url = storyUrl;
        //            item.score = storyScore;
        //            item.title = storyTitle;
        //            item.pollPartIds = storyPollIds;
        //
        //            // Top hundred position
        //            if (self.itemPosition) {
        //            item.topHundredPosition = [NSNumber numberWithInteger:[self.itemPosition integerValue]];
        //            }
    }
    
    // Top story IDs signal
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