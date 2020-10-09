//
//  TimelineViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/09/30.
//

import UIKit
import FirebaseAuth

class TimelineViewController: UIViewController {
    
    private var posts = [Post]()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(PostTableViewCell.nib(),
                           forCellReuseIdentifier: PostTableViewCell.identifier)
        tableView.isHidden = false
        return tableView
    }()
    
    private let noPostLabel: UILabel = {
        let label = UILabel()
        label.text = "No Post"
        label.isHidden = true
        return label
    }()
    
    private let postButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = UIColor.systemYellow
        button.imageView?.tintColor = .white
        button.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = "タイムライン"
        let views = [tableView, postButton, noPostLabel]
        for x in views {
            view.addSubview(x)
        }
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        FirestoreManager.shared.fetchPostFromFirestore { [weak self] (result) in
            switch result {
            case .success(let posts):
                guard !posts.isEmpty else {
                    print("posts is empty")
                    self?.tableView.isHidden = true
                    self?.noPostLabel.isHidden = false
                    return
                }
                
                self?.noPostLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.posts = posts
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("failed to get conversations!!: \(error)")
                self?.tableView.isHidden = true
                self?.noPostLabel.isHidden = false
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
        noPostLabel.frame = CGRect(x: (view.width - 50) / 2,
                                   y: (view.height - 25) / 2,
                                   width: 100,
                                   height: 50)
        
        postButton.frame = CGRect(x: UIScreen.main.bounds.size.width*8/10,
                                  y: UIScreen.main.bounds.size.height*4/5,
                                  width: UIScreen.main.bounds.size.width/6,
                                  height: UIScreen.main.bounds.size.width/6)
        
        postButton.layer.cornerRadius = postButton.frame.width/2
    }
    
    @objc private func didTapPost(){
        let vc = storyboard?.instantiateViewController(identifier: "postVC") as! PostViewController
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            if let vc = storyboard?.instantiateViewController(identifier: "loginVC") as? LoginRegisterViewController {
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: false, completion: nil)
            }
        }
    }
    
}

extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier,
                                                 for: indexPath) as! PostTableViewCell
        
        cell.configure(name: post.userName,
                       genre: post.genre,
                       imageUrl: nil,
                       comment: post.comment,
                       date: post.postDate)
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

extension TimelineViewController: PostTableViewCellDelegate {
    func moveToDetail(post: Post) {
        let vc = PostDetailViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}
