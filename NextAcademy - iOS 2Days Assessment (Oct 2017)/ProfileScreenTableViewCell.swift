//
//  ProfileScreenTableViewCell.swift
//  NextAcademy - iOS 2Days Assessment (Oct 2017)
//
//  Created by Tan Wei Liang on 24/12/2017.
//  Copyright © 2017 Tan Wei Liang. All rights reserved.
//

import UIKit

class ProfileScreenTableViewCell: UITableViewCell {

    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
