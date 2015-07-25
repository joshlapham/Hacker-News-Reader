//
//  HNRItem+CoreDataProperties.swift
//  Hacker News Reader
//
//  Created by Josh Lapham on 26/07/2015.
//  Copyright © 2015 Nerd Burger Labs. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension HNRItem {

    @NSManaged var author: String?
    @NSManaged var date: NSDate?
    @NSManaged var isDead: NSNumber?
    @NSManaged var itemId: NSNumber?
    @NSManaged var itemIsDeleted: NSNumber?
    @NSManaged var itemType: String?
    @NSManaged var parentId: NSNumber?
    @NSManaged var score: NSNumber?
    @NSManaged var text: String?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var topHundredPosition: NSNumber?
    @NSManaged var childIds: NSObject?
    @NSManaged var pollPartIds: NSObject?

}
