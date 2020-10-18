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
        userImageLabel.image = UIImage(systemName: "person.circle")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    public func configure(with comment: Comment){
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: comment.postDate)
        
        DispatchQueue.main.async { [weak self] in
            self?.userNameLabel.text = comment.userName
            self?.commentLabel.text = comment.comment
            self?.dateLabel.text = dateString
            self?.userImageLabel.image = UIImage(systemName: "person.circle")
        }
    }
    
}
