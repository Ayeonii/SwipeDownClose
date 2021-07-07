//
//  FilterTableViewCell.swift
//  SwipeDownClose
//
//  Created by 이아연 on 2021/07/07.
//

import UIKit

class FilterTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var listLabel: UILabel!
    
    var selectedList : [String] = []
    var listText : String? {
        didSet {
            if let text = listText {
                listLabel.text = text
                
                if selectedList.contains(text) {
                    checkBtn.isSelected = true
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkBtn.isSelected = false
    }
}
