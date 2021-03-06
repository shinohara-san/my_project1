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
    
    public func configure(comment: Comment){
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: comment.postDate)
        dateLabel.text = dateString
        
        FirestoreManager.shared.getUserNameForPost(id: comment.commentUserId, completion: { result in
            switch result {
            case .success(let name):
                DispatchQueue.main.async { [weak self] in
                    self?.userCommentLabel.text = "\(name)さんがあなたの投稿にコメントしました。"
                }
            case .failure(_):
                print("getUserName error")
            }
        })
        
        FirestoreManager.shared.getUserEmail(by: comment.commentUserId, completion: {[weak self] result in
            switch result {
            
            case .success(let email):
                let safeEmail = FirestoreManager.safeEmail(emailAdderess: email)
                let path = "images/\(safeEmail)"
                StorageManager.shared.downloadURL(for: path) { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.userImage.sd_setImage(with: url, completed: nil)
                    case .failure(_):
                        self?.userImage.image = UIImage(systemName: "person.circle.fill")
                    }
                }
            case .failure(_):
                self?.userImage.image = UIImage(systemName: "person.circle.fill")
                print("getUserEmail Error")
            }
        })
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
