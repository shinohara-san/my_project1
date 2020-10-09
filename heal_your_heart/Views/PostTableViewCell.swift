//
//  PostTableViewCell.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/01.
//

import UIKit

protocol PostTableViewCellDelegate: AnyObject {
    func moveToDetail()
}

class PostTableViewCell: UITableViewCell {
    
    static let identifier = "PostTableViewCell"
    public weak var delegate: PostTableViewCellDelegate?
    
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
        // Initialization code
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
    
    public func configure(name: String, genre: String, imageUrl: URL?, comment: String, date: String){
        DispatchQueue.main.async { [weak self] in
            self?.userNameLabel.text = name
            self?.commentGenreLabel.text = genre
            self?.commentLabel.text = comment
            self?.dateLabel.text = date
            if imageUrl != nil {
                
            } else {
                self?.userImageView.image = UIImage(systemName: "person.circle")
            }
        }
        
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            delegate?.moveToDetail()
        }
    }
}

