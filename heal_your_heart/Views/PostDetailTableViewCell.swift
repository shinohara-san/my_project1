//
//  PostDetailTableViewCell.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/02.
//

import UIKit

protocol PostDetailTableViewCellDelegate: AnyObject {
    
}

class PostDetailTableViewCell: UITableViewCell {
    
    static let identifier = "PostDetailTableViewCell"
    public weak var delegate: PostDetailTableViewCellDelegate?
    
    static func nib() -> UINib {
        return UINib(nibName: "PostDetailTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var cheerCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(name: String, genre: String, imageName: String?, comment: String, date: String){
        userNameLabel.text = name
        genreLabel.text = genre
        commentLabel.text = comment
        dateLabel.text = date
        userImageView.image = UIImage(systemName: "person.circle")
    }
    
}
