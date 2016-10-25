//
//  FiltersViewControllerDelegate.swift
//  Yelp
//
//  Created by Savio Tsui on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation

protocol FiltersViewControllerDelegate: class {
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: YelpFilters)
}
