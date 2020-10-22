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
    
    var post: Post?
    var username: String?
    
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
    
    @IBAction func didTapCheer(_ sender: Any) {
        guard let userId = UserDefaults.standard.value(forKey: "id") as? String,
              let postId = post?.postId else {
            return
        }
        
        FirestoreManager.shared.checkLikeExist(userId: userId, postId: postId) { likeId in
            
            if let likeId = likeId {
                FirestoreManager.shared.deleteLike(likeId: likeId, postId: postId, completion: { num in
                    DispatchQueue.main.async { [weak self] in
                        self?.cheerCountLabel.text = String(num)
                    }
                })
            } else {
                FirestoreManager.shared.addLike(userId: userId, postId: postId, completion: { num in
                    DispatchQueue.main.async { [weak self] in
                        self?.cheerCountLabel.text = String(num)
                    }
                })
                
            }
        }
    }
    
    public func configure(with post: Post){
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: post.postDate)
        
        FirestoreManager.shared.showLike(postId: post.postId) { num in
            DispatchQueue.main.async { [weak self] in
                self?.cheerCountLabel.text = String(num)
            }
        }
        
        FirestoreManager.shared.getUserNameForPost(id: post.userId, completion: { result in
            switch result {
            case .success(let name):
                DispatchQueue.main.async { [weak self] in
                    self?.userNameLabel.text = name
                }
            case .failure(_):
                print("getUserName error")
            }
        })
        
        DispatchQueue.main.async { [weak self] in
            self?.genreLabel.text = post.genre
            self?.commentLabel.text = post.comment
            self?.dateLabel.text = dateString
            self?.userImageView.image = UIImage(systemName: "person.circle")
        }
    }
    
}
