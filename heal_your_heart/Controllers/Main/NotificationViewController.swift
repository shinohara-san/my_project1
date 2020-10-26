//
//  NotificationViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/09/30.
//

import UIKit

class NotificationViewController: UIViewController {
    
    var notifications = [Comment]()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(NotificationTableViewCell.nib(),
                           forCellReuseIdentifier: NotificationTableViewCell.identifier)
        return tableView
    }()
    
    private let noNotificationLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notification"
        label.textAlignment = .center
        label.backgroundColor = .secondarySystemBackground
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "通知"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "全て既読にする",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapAllRead))
        view.backgroundColor = .systemBackground
        let views = [tableView, noNotificationLabel]
        for x in views {
            view.addSubview(x)
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noNotificationLabel.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let id = UserDefaults.standard.value(forKey: "id") as? String else {
            return
        }
        FirestoreManager.shared.fetchNotification(id: id, completion: { [weak self] result in
            switch result {
            
            case .success(let notifications):
                //                print("NotificationVC: \(notifications)")
                guard !notifications.isEmpty else {
                    self?.tableView.isHidden = true
                    self?.noNotificationLabel.isHidden = false
                    return
                }
                
                self?.notifications = notifications
                DispatchQueue.main.async {
                    self?.tableView.isHidden = false
                    self?.noNotificationLabel.isHidden = true
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("fetchNotification failed: \(error)")
                self?.tableView.isHidden = true
                self?.noNotificationLabel.isHidden = false
            }
        })
        
        FirestoreManager.shared.fetchLike(id: id, completion: { [weak self] result in
            switch result {
            case .success(let likes):
                print("likes: \(likes)")
            case .failure(_):
                print("Fetchlike failed")
            }
        })
    }
    
    @objc private func didTapAllRead(){
        //全てを既読にする処理をfirestoremanagerから
        guard let id = UserDefaults.standard.value(forKey: "id") as? String else {
            return 
        }
        FirestoreManager.shared.makeAllIsReadTrue(id: id)
    }
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier,
                                                 for: indexPath) as! NotificationTableViewCell
        
        let notification = notifications[indexPath.row]
        cell.delegate = self
        cell.configure(notification: notification, postDate: notification.postDate, actionUserId: notification.commentUserId)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

extension NotificationViewController: NotificationTableViewCellDelegate {
    func renewIsRead(commentId: String) {
        FirestoreManager.shared.makeIsReadTrue(commentId: commentId)
    }
    
    func moveToDetail(post: Post) {
        let vc = PostDetailViewController(post: post)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
}
