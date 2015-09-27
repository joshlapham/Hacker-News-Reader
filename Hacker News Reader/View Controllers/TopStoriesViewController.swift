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
import SafariServices

// MARK: - TopStoriesViewController class
class TopStoriesViewController: UITableViewController, NSFetchedResultsControllerDelegate, SFSafariViewControllerDelegate {
    // MARK: Properties
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "HNRItem")
        
        // Sort by Item top 100 position
        let sortDescriptor = NSSortDescriptor(key: "topHundredPosition", ascending: true)
        fetchRequest.sortDescriptors = [ sortDescriptor ]
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()
    
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
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
                // TODO: refactor NSOperation logic here to optimise fetching
                let operationQueue = NSOperationQueue()
                
                for var itemDict in topItems {
                    // Fetch item
                    let operation = ItemFetchOperation(moc: self.managedObjectContext, dict: itemDict as! NSDictionary)
                    operationQueue.addOperation(operation)
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
                let topItems = NSMutableArray()
                
                // Loop over received data to get top story IDs
                let enumerator = snapshot.children
                
                while let childSnap: FDataSnapshot = enumerator.nextObject() as! FDataSnapshot! {
                    // Only fetch itemsCountToFetch
                    if topItems.count == itemCountToFetch {
                        break
                    }
                    
                    // Item position in top 100
                    // NOTE - adjusting for 0-based index
                    var positionAdjusted = Int(childSnap.name)!
                    positionAdjusted = positionAdjusted + 1
                    let topItemPosition = positionAdjusted
                    
                    // Item ID
                    let topItemId = childSnap.value
                    
                    // Init item dict
                    // TODO: update constant names
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

// MARK: - SFSafariViewControllerDelegate methods extension
extension TopStoriesViewController {
    // MARK: Methods
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UITableViewDelegate methods extension
extension TopStoriesViewController {
    // MARK: Methods
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Init cell data
        let cellData = self.fetchedResultsController.objectAtIndexPath(indexPath) as! HNRItem
        
        // TODO: handle nil cellData.url, as this will be for a 'Ask HN' type story
        guard let itemURL = cellData.url else {
            return
        }
        
        guard itemURL.isEmpty == false else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            return
        }
        
        // Init Safari VC and present
        let destinationViewController = SFSafariViewController(URL: NSURL(string: itemURL)!, entersReaderIfAvailable: true)
        destinationViewController.delegate = self
        self.presentViewController(destinationViewController, animated: true, completion: nil)
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
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section] as NSFetchedResultsSectionInfo
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Init cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ItemCell
        
        // Init cell data
        let cellData = self.fetchedResultsController.objectAtIndexPath(indexPath) as! HNRItem
        
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
                    withRowAnimation: UITableViewRowAnimation.Top)
                
            case .Delete:
                tableView.deleteSections(NSIndexSet(index: sectionIndex),
                    withRowAnimation: UITableViewRowAnimation.Fade)
                
            default:
                break
            }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
            
        case .Insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath],
                    withRowAnimation:UITableViewRowAnimation.Top)
            }
            
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath],
                    withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
        case .Update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ItemCell! {
                    let cellData = controller.objectAtIndexPath(indexPath) as! HNRItem
                    cell.configureCellWithData(cellData)
                }
            }
            
        case .Move:
            if let indexPath = indexPath {
                if let newIndexPath = newIndexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath],
                        withRowAnimation: UITableViewRowAnimation.Fade)
                    tableView.insertRowsAtIndexPaths([newIndexPath],
                        withRowAnimation: UITableViewRowAnimation.Top)
                }
            }
        }
    }
}