//
//  PostDetailViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/02.
//

import UIKit

class PostDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let post: Post?
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var sections = ["", "　コメント"]
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(PostDetailTableViewCell.nib(),
                           forCellReuseIdentifier: PostDetailTableViewCell.identifier)
        tableView.register(CommentTableViewCell.nib(),
                           forCellReuseIdentifier: CommentTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "詳細"
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
    
    @objc private func didTapPost(){
        print("コメント書く")
    }
    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        let label : UILabel = UILabel(frame: CGRect(x: 10,
                                                    y: 10,
                                                    width: view.frame.width / 3,
                                                    height: headerView.frame.height - 20))
        label.textColor = .gray
        label.text = "コメント"
        
        let button = UIButton(frame: CGRect(x: 10 + label.frame.width,
                                            y: 10,
                                            width: view.frame.width / 3,
                                            height: headerView.frame.height - 20))
        button.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
        
        headerView.addSubview(label)
        headerView.addSubview(button)
        
        return headerView
    }
    
}

extension PostDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailTableViewCell.identifier,
                                                     for: indexPath) as! PostDetailTableViewCell
            cell.selectionStyle = .none
            guard let post = post else {return UITableViewCell()}
            
            cell.configure(with: post)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier,
                                                     for: indexPath) as! CommentTableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 40
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 200
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return UIView()
        case 1:
            return createTableHeader()
        default:
            print("Error: ViewForHeader")
            break
        }
        return nil
    }
}
