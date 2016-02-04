//
//  MovieCell.swift
//  Flicks
//
//  Created by dong liang on 2/3/16.
//  Copyright © 2016 dong. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var postview: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
