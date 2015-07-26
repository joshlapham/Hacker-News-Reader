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

// MARK: - TopStoriesViewController class
class TopStoriesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    // MARK: Properties
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "HNRItem")
        
        // TODO: update key here
        let sortDescriptor = NSSortDescriptor(key: "itemId", ascending: true)
        fetchRequest.sortDescriptors = [ sortDescriptor ]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter.new()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateFormatter
        }()
    
    // MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Top Stories"
        
        // Setup tableView
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        // TODO: delete this eventually!
        self.tableView.allowsSelection = false
        
        // Core Data fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            abort()
        }
        
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
            
            // Item date
            let storyTime = snapshot.value[FirebaseAPIKey.storyTime] as! NSNumber
            let timeInterval = storyTime.doubleValue as NSTimeInterval
            let storyDate = NSDate(timeIntervalSince1970: timeInterval)
            
            // TODO: fix commented properties
            //            BOOL isDeleted = (BOOL)snapshot.value[@"deleted"];
            //            let isDeleted = snapshot.value[FirebaseAPIKey.isDeleted] as! Bool
            
            
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
            let item = NSEntityDescription.insertNewObjectForEntityForName("HNRItem", inManagedObjectContext: self.managedObjectContext) as! HNRItem
            
            // Set properties
            item.itemId = storyId
            item.itemType = storyType
            item.author = storyAuthor
            item.url = storyUrl
            item.title = storyTitle
            item.date = storyDate
            
            // TODO: fix commented properties
            //            item.itemIsDeleted = isDeleted
            //            item.isDead = NSNumber(bool: deadOrNot)
            //            item.parentId = storyParentId
        })
        
        // TODO: finish implementing these properties
        //            // Set details
        //            item.itemIsDeleted = [NSNumber numberWithBool:isDeleted];
        //            item.text = storyText;
        //            item.isDead = [NSNumber numberWithBool:deadOrNot];
        //            item.parentId = storyParentId;
        //            item.childIds = storyChildIds;
        //            item.score = storyScore;
        //            item.pollPartIds = storyPollIds;
        //
        //            // Top hundred position
        //            if (self.itemPosition) {
        //            item.topHundredPosition = [NSNumber numberWithInteger:[self.itemPosition integerValue]];
        //            }
        
        // Save to Core Data
        // TODO: refactor logic to only save after all items have been fetched
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            abort()
        }
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

// MARK: - UITableViewDataSource delegate methods extension
extension TopStoriesViewController {
    // MARK: Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = self.fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section] as NSFetchedResultsSectionInfo
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Init cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ItemCell
        
        // Init cell data
        let cellData = fetchedResultsController.objectAtIndexPath(indexPath) as! HNRItem
        
        // Configure cell
        cell.configureCellWithData(cellData)
        
        return cell
    }
}

// MARK: - Fetched results controller methods extension
extension TopStoriesViewController {
    // MARK: NSFetchedResultsControllerDelegate methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            switch(type) {
                
            case .Insert:
                tableView.insertSections(NSIndexSet(index: sectionIndex),
                    withRowAnimation: UITableViewRowAnimation.Fade)
                
            case .Delete:
                tableView.deleteSections(NSIndexSet(index: sectionIndex),
                    withRowAnimation: UITableViewRowAnimation.Fade)
                
            default:
                break
            }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
            
        case .Insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath],
                    withRowAnimation:UITableViewRowAnimation.Fade)
            }
            
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath],
                    withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
        case .Update:
            if let indexPath = indexPath {
                tableView.cellForRowAtIndexPath(indexPath)
                
                // TODO: update here once custom cell class implemented
                //                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? UITableViewCell! {
                //                                configureCell(cell, withObject: object)
                //                }
            }
            
        case .Move:
            if let indexPath = indexPath {
                if let newIndexPath = newIndexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath],
                        withRowAnimation: UITableViewRowAnimation.Fade)
                    tableView.insertRowsAtIndexPaths([newIndexPath],
                        withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }
        }
    }
}