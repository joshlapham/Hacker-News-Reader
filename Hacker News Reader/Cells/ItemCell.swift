//
//  ItemCell.swift
//  Hacker News Reader
//
//  Created by Josh Lapham on 27/07/2015.
//  Copyright © 2015 Nerd Burger Labs. All rights reserved.
//

import Foundation

// MARK: - ItemCell class
class ItemCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet var itemId: UILabel!
    @IBOutlet var itemTitle: UILabel!
    
    // MARK: Awake from NIB (init) method
    override func awakeFromNib() {
        // TODO: implement
        
        // Style cell
    }
}

// MARK: - Helper methods extension
extension ItemCell {
    // MARK: Methods
    // Configure cell with data
    func configureCellWithData(cellData: HNRItem!) {
        self.itemId.text = cellData.itemId?.stringValue
        self.itemTitle.text = cellData.title
    }
}