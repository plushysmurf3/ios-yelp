//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftIconFont

class BusinessesViewController: UIViewController {
    
    fileprivate var businesses: [Business]!
    fileprivate var yelpFilters = YelpFilters()

    fileprivate var searchBar: UISearchBar!
    fileprivate var navigateSettingsButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: BusinessesViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the UISearchBar
        self.searchBar = UISearchBar()
        self.searchBar.delegate = self

        // Add SearchBar to the NavigationBar
        self.searchBar.sizeToFit()
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.leftBarButtonItem?.icon(from: .FontAwesome, code: "yelp", ofSize: 20)

        // Initialize the UITableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.yelpFilters.searchString = "Thai"
        self.searchBar.text = self.yelpFilters.searchString

        doSearch(filters: self.yelpFilters)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController

        self.delegate = filtersViewController
        self.delegate?.businessesViewController(businessesViewController: self, onNavigateAway: self.yelpFilters)

        filtersViewController.delegate = self
    }

    // Perform the search.
    fileprivate func doSearch(filters: YelpFilters) {

        MBProgressHUD.showAdded(to: self.view, animated: true)

        let searchString: String = filters.searchString!
        let sort: YelpSortMode = toYelpSortMode(sort: filters.sort)
        let categories = filters.categories
        let deals = filters.deals
        let distance = filters.distance

        Business.searchWithTerm(term: searchString, sort: sort, categories: categories, deals: deals, distance: distance, completion: {
            (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.printBusinesses(businesses: businesses)
            MBProgressHUD.hide(for: self.view, animated: true)
        })
    }

    fileprivate func toYelpSortMode(sort: String?) -> YelpSortMode {

        if (sort == nil) {
            return YelpSortMode.bestMatched
        }

        switch sort! {
            case "1":
                return YelpSortMode.distance
            case "2":
                return YelpSortMode.highestRated
            default:
                return YelpSortMode.bestMatched
        }
    }

    fileprivate func printBusinesses(businesses: [Business]?) {
        if let businesses = businesses {
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
    }
}

extension BusinessesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.businesses != nil) ? self.businesses.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.yelp.restaurantcell", for: indexPath) as! BusinessCell

        cell.business = businesses[indexPath.row]

        return cell
    }
}

extension BusinessesViewController: UITableViewDelegate {
}

// SearchBar methods
extension BusinessesViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.yelpFilters.searchString = ""
        doSearch(filters: self.yelpFilters)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.yelpFilters.searchString = searchBar.text
        searchBar.resignFirstResponder()
        doSearch(filters: self.yelpFilters)
    }
}

// FiltersViewControllerDelegate
extension BusinessesViewController: FiltersViewControllerDelegate {
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: YelpFilters) {
        self.yelpFilters = filters
        doSearch(filters: self.yelpFilters)
    }
}
