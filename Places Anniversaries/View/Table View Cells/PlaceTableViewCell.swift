//
//  PlaceTableViewCell.swift
//  Places Anniversaries
//
//  Created by Sameh Salama on 10/23/19.
//  Copyright © 2019 Sameh Salama. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAnniversariesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        placeImageView.layer.masksToBounds = true
        placeImageView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
