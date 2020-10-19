//
//  PostTableViewCell.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/01.
//

import UIKit

protocol PostTableViewCellDelegate: AnyObject {
    func moveToDetail(post: Post)
}

class PostTableViewCell: UITableViewCell {
    
    static let identifier = "PostTableViewCell"
    public weak var delegate: PostTableViewCellDelegate?
    
    var post: Post?
    
    static func nib() -> UINib {
        return UINib(nibName: "PostTableViewCell", bundle: nil)
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentGenreLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var cheerCountLabel: UILabel!
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
    
    @IBAction func didTapCheerButton(_ sender: Any) {
        //いいねの増減
    }
    
    public func configure(post: Post){
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: post.postDate)
        
        DispatchQueue.main.async { [weak self] in
            self?.userNameLabel.text = post.userName
            self?.commentGenreLabel.text = post.genre
            self?.commentLabel.text = post.comment
            self?.dateLabel.text = dateString
            if post.imageUrl != nil {
                //ユーザー固有の画像
            } else {
                self?.userImageView.image = UIImage(systemName: "person.circle")
            }
        }
        
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            guard let post = post else {return}
            delegate?.moveToDetail(post: post)
        }
    }
}

