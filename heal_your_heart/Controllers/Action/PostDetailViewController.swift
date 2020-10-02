//
//  PostDetailViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/02.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    private var sections = ["", "　コメント"]
//    private var values = [[Post](), [Comment]()] as [Any]
    
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
            cell.configure(name: "しのはら", genre: "将来について", imageName: nil, comment: "生のバナナには、種のできるものがありますが、私たちがふだん食べているバナナに種はありません。皮をむけば丸ごと食べられます。しかし、バナナを輪切りにしてよく見てみると、中心近くに黒いつぶがあることがわかります。この黒いつぶは、種になるはずの部分ですが、大きくはなりません。", date: "2020/10/01")
            
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
            return 25
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
            let label : UILabel = UILabel()
            label.textColor = .gray
            label.text = sections[section]
            return label
        default:
            print("Error: ViewForHeader")
            break
        }
        return nil
    }
}
