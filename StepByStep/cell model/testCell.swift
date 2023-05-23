//
//  testCell.swift
//  StepByStep
//
//  Created by Yune gim on 2023/05/02.
//

import UIKit

class testCell: UITableViewCell {

    @IBOutlet var delCehckBox: CheckBox!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var discLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        delCehckBox.isChecked = false
        delCehckBox.isHidden = true
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        //contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top:16, left: 0, bottom: 16, right: 0))
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
