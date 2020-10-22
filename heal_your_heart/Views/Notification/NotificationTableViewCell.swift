//
//  NotificationTableViewCell.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/02.
//

import UIKit

protocol NotificationTableViewCellDelegate: AnyObject {
    func moveToDetail(post: Post)
    func renewIsRead(commentId: String)
}

class NotificationTableViewCell: UITableViewCell {
    
    var comment: Comment?
    
    static let identifier = "NotificationTableViewCell"
    
    public weak var delegate: NotificationTableViewCellDelegate?
    
    static func nib() -> UINib {
        return UINib(nibName: "NotificationTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userCommentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.delegate = self
        contentView.addGestureRecognizer(tapGesture)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    public func configure(userName: String, type: String, date: Date){
        userCommentLabel.text = "\(userName)さんがあなたの投稿に\(type)しました。"
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: date)
        dateLabel.text = dateString
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            guard let comment = comment else {
                return
            }
            
            FirestoreManager.shared.getPost(by: comment.postId, completion: { [weak self] result in
                switch result {
                case .success(let post):
                    self?.delegate?.moveToDetail(post: post)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
            
            delegate?.renewIsRead(commentId: comment.commentId)
        }
    }
    
}
