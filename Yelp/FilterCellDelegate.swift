//
//  FilterCellDelegate.swift
//  Yelp
//
//  Created by Savio Tsui on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation

@objc protocol FilterCellDelegate: class {
    @objc optional func filterCell(filterCell: FilterCell, didChangeValue value: Bool)
}
