//
//  testCell.swift
//  StepByStep
//
//  Created by Yune gim on 2023/05/02.
//

import UIKit

class testCell: UITableViewCell {

    @IBOutlet var delCehckBox: CheckBox!
    
    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delCehckBox.isChecked = false
        delCehckBox.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
