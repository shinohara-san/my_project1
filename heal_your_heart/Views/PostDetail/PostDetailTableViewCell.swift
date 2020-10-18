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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    public func configure(with post: Post){
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: post.postDate)
        
        DispatchQueue.main.async { [weak self] in
            self?.userNameLabel.text = post.userName
            self?.genreLabel.text = post.genre
            self?.commentLabel.text = post.comment
            self?.dateLabel.text = dateString
            self?.userImageView.image = UIImage(systemName: "person.circle")
        }
    }
    
}
