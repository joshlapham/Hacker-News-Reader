//
//  ItemFetchOperation.swift
//  Hacker News Reader
//
//  Created by Josh Lapham on 27/07/2015.
//  Copyright © 2015 Nerd Burger Labs. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Constants
// HN API keys
// TODO: update constant names
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

// MARK: - ItemFetchOperation class
class ItemFetchOperation: NSOperation {
    // MARK: Properties
    var mainManagedObjectContext: NSManagedObjectContext!
    var privateManagedObjectContext: NSManagedObjectContext!
    var itemDict: NSDictionary!
    
    init(moc: NSManagedObjectContext!, dict: NSDictionary!) {
        super.init()
        self.mainManagedObjectContext = moc
        self.itemDict = dict
        
        // Init private managed object context
        self.privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.privateManagedObjectContext.parentContext = self.mainManagedObjectContext
    }
    
    // MARK: - Methods
    override func main() {
        // Fetch data
        let storyId = itemDict[kApiKeyId] as! NSNumber
        let storyPosition = itemDict[kApiKeyPosition] as! NSNumber
        
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
            let storyScore = snapshot.value[FirebaseAPIKey.storyScore] as? NSNumber
            
            // Item date
            let storyTime = snapshot.value[FirebaseAPIKey.storyTime] as! NSNumber
            let timeInterval = storyTime.doubleValue as NSTimeInterval
            let storyDate = NSDate(timeIntervalSince1970: timeInterval)
            
            // Item child IDs
            // NOTE - this is used for comment count
            let storyChildIds = snapshot.value[FirebaseAPIKey.storyChildIds] as? [AnyObject]
            
            // NOTE - storyText is for Ask HN type items; not relevant for most top 100 items
            let storyText = snapshot.value[FirebaseAPIKey.storyText] as? String
            
            // TODO: need to check return value of these properties with other Item types (polls, ask HN)
            
            //            let storyPollIds = snapshot.value[FirebaseAPIKey.storyPollIds]
            //            print(storyPollIds)
            //            NSArray *storyPollIds = [NSArray arrayWithArray:snapshot.value[@"parts"]];
            
            //            BOOL isDeleted = (BOOL)snapshot.value[@"deleted"];
            //                        let isDeleted = snapshot.value[FirebaseAPIKey.isDeleted]
            //            print(isDeleted)
            
            //                        let deadOrNot = snapshot.value[FirebaseAPIKey.deadOrNot]
            //            print(deadOrNot)
            //            BOOL deadOrNot = (BOOL)snapshot.value[@"dead"];
            
            //                                    let storyParentId = snapshot.value[FirebaseAPIKey.storyParentId]
            //            NSNumber *storyParentId = snapshot.value[@"parent"];
            
            // Init HNRItem
            // TODO: init in private managed object context
            let item = NSEntityDescription.insertNewObjectForEntityForName("HNRItem", inManagedObjectContext: self.mainManagedObjectContext) as! HNRItem
            
            // Set properties
            item.itemId = storyId
            item.itemType = storyType
            item.author = storyAuthor
            item.url = storyUrl
            item.title = storyTitle
            item.date = storyDate
            item.topHundredPosition = storyPosition
            item.childIds = storyChildIds
            item.text = storyText
            item.score = storyScore
        })
        
        // Save managed object context
        // TODO: update syntax here with hasChanges call
        do {
            // TODO: save on private context
            try self.mainManagedObjectContext.save()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
}