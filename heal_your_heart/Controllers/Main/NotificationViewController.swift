//
//  NotificationViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/09/30.
//

import UIKit

class NotificationViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(NotificationTableViewCell.nib(),
                           forCellReuseIdentifier: NotificationTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "通知"
        view.backgroundColor = .systemBackground
        let views = [tableView]
        for x in views {
            view.addSubview(x)
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier,
                                                 for: indexPath) as! NotificationTableViewCell
        cell.delegate = self
        return cell
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

extension NotificationViewController: NotificationTableViewCellDelegate {
    func moveToDetail() {
        let vc = PostDetailViewController(post: Post(userName: "テスト",
                                                     imageUrl: nil,
                                                     genre: "テストについて",
                                                     comment: "テストだよ",
                                                     postDate: Date()))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
