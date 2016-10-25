//
//  FilterCell.swift
//  Yelp
//
//  Created by Savio Tsui on 10/23/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {
    
    @IBOutlet weak var showAll: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterSwitch: UISwitch!
    var filterValue: AnyObject!

    weak var delegate: FilterCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        filterSwitch.addTarget(self, action: #selector(FilterCell.onFilterSwitchValueChanged), for: UIControlEvents.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func onFilterSwitchValueChanged() {
        delegate?.filterCell?(filterCell: self, didChangeValue: filterSwitch.isOn)
    }
}
