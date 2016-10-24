//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Savio Tsui on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    weak var delegate: FiltersViewControllerDelegate?

    var yelpFilters: YelpFilters?

    fileprivate let OFFERING_A_DEAL = 0
    fileprivate let DISTANCE = 1
    fileprivate let SORT_BY = 2
    fileprivate let CATEGORY = 3

    fileprivate var categories: [[String: String]]!
    fileprivate var categorySwitchStates = [Int: Bool]()

    fileprivate var filterTableData: [[[String: String]]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        initialize()
    }

    func initialize() {
        self.yelpFilters = self.yelpFilters ?? YelpFilters()

        filterTableData.append(YelpFilterData.offeringDeal)
        filterTableData.append(YelpFilterData.distance)
        filterTableData.append(YelpFilterData.sort)
        filterTableData.append(YelpFilterData.categories)

        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearch(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)

        var filters = [String : AnyObject]()

        var selectedCategories = [String]()
        for (row, isSelected) in categorySwitchStates {
            if (isSelected) {
                selectedCategories.append(filterTableData[self.CATEGORY][row]["code"]!)
            }
        }

        if (selectedCategories.count > 0) {
            filters["categories"] = selectedCategories as AnyObject?
        }

        delegate?.filtersViewController!(filtersViewController: self, didUpdateFilters: filters)
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filterTableData[self.CATEGORY].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.yelp.filtercell", for: indexPath) as! FilterCell

        var category = filterTableData[self.CATEGORY][indexPath.row]
        cell.filterLabel.text = category["name"]
        cell.filterSwitch.isOn = categorySwitchStates[indexPath.row] ?? false
        cell.delegate = self

        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
}

extension FiltersViewController: FilterCellDelegate {
    func filterCell(filterCell: FilterCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: filterCell)!

        categorySwitchStates[indexPath.row] = value
    }
}

extension FiltersViewController: BusinessesViewControllerDelegate {
    func businessesViewController(businessesViewController: BusinessesViewController, onNavigateAway yelpFilters: YelpFilters) {
        self.yelpFilters = yelpFilters
    }
}
