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

    fileprivate var categories: [String] = []
    fileprivate var categorySwitchStates = [Int: Bool]()
    fileprivate var categoriesCollapsed: Bool = true

    fileprivate var offeringDealState: Bool = false

    fileprivate var distanceCollapsed: Bool = true
    fileprivate var distanceState: String = ""

    fileprivate var sortByState: String = "0"
    fileprivate var sortByCollapsed: Bool = true

    fileprivate var filterTableData: [[[String: String]]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 120
        self.tableView.rowHeight = UITableViewAutomaticDimension

        initialize()
    }

    func initialize() {
        self.yelpFilters = self.yelpFilters ?? YelpFilters()

        // ingest incoming filters to set up initial state
        offeringDealState = (self.yelpFilters?.deals) ?? false
        distanceState = self.yelpFilters?.distance ?? ""
        sortByState = (self.yelpFilters?.sort) ?? "0"

        categories.removeAll()
        for category in (self.yelpFilters?.categories)! {
            categories.append(category)
        }

        // populate filter data
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

        var filters = YelpFilters()

        var selectedCategories = [String]()
        for (row, isSelected) in categorySwitchStates {
            if (isSelected) {
                selectedCategories.append(filterTableData[YelpFilterTypes.CATEGORY][row]["code"]!)
            }
        }

        if (selectedCategories.count > 0) {
            filters.categories = selectedCategories
        }

        filters.searchString = yelpFilters?.searchString
        filters.sort = self.sortByState
        filters.distance = self.distanceState
        filters.deals = self.offeringDealState

        delegate?.filtersViewController(filtersViewController: self, didUpdateFilters: filters)
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch (section)
        {
        case YelpFilterTypes.DISTANCE:
            if (self.distanceCollapsed) {
                self.filterTableData[section] = YelpFilterData.distance.filter({$0["value"] == self.distanceState})
            }
            else {
                self.filterTableData[section] = YelpFilterData.distance
            }
            break
        case YelpFilterTypes.SORT_BY:
            if (self.sortByCollapsed) {
                self.filterTableData[section] = YelpFilterData.sort.filter({$0["value"] == self.sortByState})
            }
            else {
                self.filterTableData[section] = YelpFilterData.sort
            }
            break
        case YelpFilterTypes.CATEGORY:
            if (self.categoriesCollapsed) {
                if (categories.count > 0) {
                    self.filterTableData[section] = YelpFilterData.categories.filter({categories.contains($0["code"]!)})
                    self.filterTableData[section].append(["name" : "Show All", "code": ""])
                }
                else {
                    if (YelpFilterData.categories.count >= 5) {
                        self.filterTableData[section].removeAll()
                        for i in (0..<5) {
                            self.filterTableData[section].append(YelpFilterData.categories[i])
                        }

                        self.filterTableData[section].append(["name" : "Show All", "code": ""])
                    }
                    else {
                        self.filterTableData[section] = YelpFilterData.categories
                    }
                }
            }
            else {
                self.filterTableData[section] = YelpFilterData.categories
            }
            break
        default:
            break
        }

        return self.filterTableData[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.yelp.filtercell", for: indexPath) as! FilterCell

        let data = self.filterTableData[indexPath.section][indexPath.row]

        cell.showAll.isHidden = true
        cell.filterLabel.isHidden = false
        switch (indexPath.section)
        {
        case YelpFilterTypes.DISTANCE:
            cell.filterLabel.text = data["distance"]
            cell.filterSwitch.isHidden = true
            cell.filterValue = data["value"] as AnyObject!
            cell.accessoryType = .none
            if (data["value"] == self.distanceState) {
                if (self.distanceCollapsed) {
                    cell.accessoryType = .disclosureIndicator
                }
                else {
                    cell.accessoryType = .checkmark
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.default;
            break
        case YelpFilterTypes.SORT_BY:
            cell.filterLabel.text = data["type"]
            cell.filterSwitch.isHidden = true
            cell.filterValue = data["value"] as AnyObject!
            cell.accessoryType = .none
            if (data["value"] == self.sortByState) {
                if (self.sortByCollapsed) {
                    cell.accessoryType = .disclosureIndicator
                }
                else {
                    cell.accessoryType = .checkmark
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.default;
            break
        case YelpFilterTypes.CATEGORY:
            if (data["code"] == "") {
                cell.filterLabel.isHidden = true
                cell.filterSwitch.isHidden = true
                cell.showAll.isHidden = false
                cell.filterValue = data["code"] as AnyObject!
                break;
            }

            cell.filterLabel.text = data["name"]
            cell.filterSwitch.isHidden = false
            cell.filterSwitch.isOn = self.categories.contains(data["code"]!)
            categorySwitchStates[indexPath.row] = cell.filterSwitch.isOn
            cell.filterValue = data["code"] as AnyObject!
            cell.accessoryType = .none
            cell.selectionStyle = UITableViewCellSelectionStyle.none;
            cell.delegate = self
            break
        default:
            cell.filterLabel.text = data["name"]
            cell.filterSwitch.isHidden = false
            cell.filterSwitch.isOn = self.offeringDealState
            cell.accessoryType = .none
            cell.selectionStyle = UITableViewCellSelectionStyle.none;
            cell.delegate = self
            break
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filterTableData.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case YelpFilterTypes.DISTANCE:
                return "Distance"
            case YelpFilterTypes.SORT_BY:
                return "Sort By"
            case YelpFilterTypes.CATEGORY:
                return "Category"
            default:
                return ""
        }
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filterCell = tableView.cellForRow(at: indexPath) as! FilterCell

        switch indexPath.section {
        case YelpFilterTypes.DISTANCE:
            self.distanceState = filterCell.filterValue as! String
            self.distanceCollapsed = !self.distanceCollapsed
            break
        case YelpFilterTypes.SORT_BY:
            self.sortByState = filterCell.filterValue as! String
            self.sortByCollapsed = !self.sortByCollapsed
            break
        case YelpFilterTypes.CATEGORY:
            if (filterCell.filterValue as! String == "") {
                self.categoriesCollapsed = !self.categoriesCollapsed
                break
            }
            return
        default:
            return
        }

        tableView.reloadSections([indexPath.section], with: .automatic)
    }
}

extension FiltersViewController: FilterCellDelegate {
    func filterCell(filterCell: FilterCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: filterCell)!
        switch indexPath.section {
        case YelpFilterTypes.CATEGORY:
            self.categorySwitchStates[indexPath.row] = value
            break
        case YelpFilterTypes.OFFERING_A_DEAL:
            self.offeringDealState = filterCell.filterSwitch.isOn
            break
        default:
            break
        }
    }
}

extension FiltersViewController: BusinessesViewControllerDelegate {
    func businessesViewController(businessesViewController: BusinessesViewController, onNavigateAway yelpFilters: YelpFilters) {
        self.yelpFilters = yelpFilters
    }
}
