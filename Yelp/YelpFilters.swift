//
//  YelpFilters.swift
//  Yelp
//
//  Created by Savio Tsui on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation

// Model class that represents the user's search settings
struct YelpFilters {
    var searchString: String? = ""
    var categories: [String]? = []
    var sort: String? = nil
    var deals: Bool? = nil
    var distance: String? = nil
}
