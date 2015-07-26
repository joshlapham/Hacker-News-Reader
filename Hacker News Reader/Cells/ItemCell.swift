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
        // Style cell
        self.itemTitle.numberOfLines = 0
        // TODO: move this to a constant elsewhere and update calculation
        let maxWidthForTitle = UIScreen.mainScreen().bounds.size.width - 100
        self.itemTitle.preferredMaxLayoutWidth = maxWidthForTitle
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