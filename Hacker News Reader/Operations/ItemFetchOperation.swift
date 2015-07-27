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
            
            // Item date
            let storyTime = snapshot.value[FirebaseAPIKey.storyTime] as! NSNumber
            let timeInterval = storyTime.doubleValue as NSTimeInterval
            let storyDate = NSDate(timeIntervalSince1970: timeInterval)
            
            // Item child IDs
            // NOTE - this is used for comment count
            //            print(snapshot.value[FirebaseAPIKey.storyChildIds])
            let storyChildIds = snapshot.value[FirebaseAPIKey.storyChildIds] as? [AnyObject]
            //            print(storyChildIds)
            
            // TODO: fix commented properties
            //            BOOL isDeleted = (BOOL)snapshot.value[@"deleted"];
            //            let isDeleted = snapshot.value[FirebaseAPIKey.isDeleted] as! Bool
            
            //            let deadOrNot = snapshot.value[FirebaseAPIKey.deadOrNot] as! Bool
            //            BOOL deadOrNot = (BOOL)snapshot.value[@"dead"];
            
            //            let storyParentId = snapshot.value[FirebaseAPIKey.storyParentId] as! NSNumber
            //            NSNumber *storyParentId = snapshot.value[@"parent"];
            
            //            NSString *storyText = snapshot.value[@"text"];
            //            NSArray *storyPollIds = [NSArray arrayWithArray:snapshot.value[@"parts"]];
            //            NSNumber *storyScore = snapshot.value[@"score"];
            
            // Init HNRItem
            // TODO: init in private managed object context
            var item = NSEntityDescription.insertNewObjectForEntityForName("HNRItem", inManagedObjectContext: self.mainManagedObjectContext) as! HNRItem
            
            // Set properties
            item.itemId = storyId
            item.itemType = storyType
            item.author = storyAuthor
            item.url = storyUrl
            item.title = storyTitle
            item.date = storyDate
            item.topHundredPosition = storyPosition
            item.childIds = storyChildIds
            
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
        //            item.score = storyScore;
        //            item.pollPartIds = storyPollIds;
        
        // Save managed object context
        do {
            // TODO: save on private context
            try self.mainManagedObjectContext.save()
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
}