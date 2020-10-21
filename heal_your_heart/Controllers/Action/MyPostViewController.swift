//
//  MyPostViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/21.
//

import UIKit

class MyPostViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
//    var posts = [Post]()
    var posts = [Post(userName: "るい", genre: "人生について", comment: "あああ", postDate: Date(), postId: "fjakkl", userId: "jflaj;fl")]
    
    private let noPostLabel: UILabel = {
        let label = UILabel()
        label.text = "No Post"
        label.isHidden = true
        label.textAlignment = .center
        label.backgroundColor = .secondarySystemBackground
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noPostLabel)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        footer.backgroundColor = .systemGroupedBackground
        tableView.tableFooterView = footer
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //posts from firestore 値によってtableとlabelの表示を変える
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPostLabel.frame = view.bounds
    }
    
}

extension MyPostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        cell.configure(post: post)
        cell.post = post
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
}

extension MyPostViewController: PostTableViewCellDelegate {
    func moveToDetail(post: Post) {
        let vc = PostDetailViewController(post: post)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
}
