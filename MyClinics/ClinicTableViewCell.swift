//
//  ClinicTableViewCell.swift
//  MyClinics
//
//  Created by Meori Lehr on 31/01/2017.
//  Copyright © 2017 meori.noa. All rights reserved.
//

import UIKit

class ClinicTableViewCell: UITableViewCell {

  @IBOutlet weak var myImage: UIImageView!
  @IBOutlet weak var myNameLabel: UILabel!
  @IBOutlet weak var myAddressLabel: UILabel!
  @IBOutlet weak var myRankLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
