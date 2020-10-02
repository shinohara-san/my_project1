//
//  CommentTableViewCell.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/02.
//

import UIKit

protocol CommentTableViewCellDelegate: AnyObject {
    
}

class CommentTableViewCell: UITableViewCell {
    
    static let identifier = "CommentTableViewCell"
    public weak var delegate: CommentTableViewCellDelegate?
    
    static func nib() -> UINib {
        return UINib(nibName: "CommentTableViewCell", bundle: nil)
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userImageLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageLabel.image = UIImage(systemName: "person.circle")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
