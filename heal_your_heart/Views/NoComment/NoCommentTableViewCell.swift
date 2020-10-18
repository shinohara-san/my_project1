//
//  NoCommentTableViewCell.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/13.
//

import UIKit

class NoCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var noCommentLabel: UILabel!
    
    static let identifier = "NoCommentTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "NoCommentTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        noCommentLabel.text = "No Comments Found"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
