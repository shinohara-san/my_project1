//
//  PostDetailViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/02.
//

import UIKit

class KeyboardOverlay {
    static var newTop: CGFloat = 0
    static var currentTop: CGFloat = 0
}

class PostDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var post: Post?
    var comments: [Comment]?
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var sections = ["", "コメント"]
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(PostDetailTableViewCell.nib(),
                           forCellReuseIdentifier: PostDetailTableViewCell.identifier)
        tableView.register(CommentTableViewCell.nib(),
                           forCellReuseIdentifier: CommentTableViewCell.identifier)
        tableView.register(NoCommentTableViewCell.nib(),
                           forCellReuseIdentifier: NoCommentTableViewCell.identifier)
        return tableView
    }()
    
    private let commentFieldView: UIView = {
        let uiview = UIView()
        uiview.backgroundColor = .systemBackground
        return uiview
    }()
    
    private let commentTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .systemBackground
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.cornerRadius = 10
        field.leftView = UIView(frame: CGRect(x: 5, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.setTitle("送信", for: .normal)
        button.backgroundColor = .link
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "詳細"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "閉じる",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didTapClose))
        view.backgroundColor = .systemBackground
        let views = [tableView, commentFieldView]
        for x in views {
            view.addSubview(x)
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        commentTextField.delegate = self
        
        let subviews = [commentTextField, commentButton]
        for x in subviews {
            commentFieldView.addSubview(x)
        }
        
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChange),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        // 処理
        if sender.state == .ended {
            commentTextField.resignFirstResponder()
        }
    }
    
    @objc private func didTapClose(){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = CGRect(x: 0, y: 0,
                                 width: view.frame.width,
                                 height: view.frame.height)
        
        commentFieldView.frame = CGRect(x: 0,
                                        y: view.height - 80,
                                        width: view.frame.width,
                                        height: 80)
        
        commentTextField.frame = CGRect(x: 10,
                                        y: 20,
                                        width: commentFieldView.frame.width * 2.25 / 3,
                                        height: 40)
        
        commentButton.frame = CGRect(x: 10 + commentTextField.frame.width + 10,
                                     y: 20,
                                     width: commentFieldView.frame.width - 30 - commentTextField.frame.width,
                                     height: 40)
    }
    
    func closeKeyboard() {
        commentTextField.endEditing(true)
    }
    
    @objc func keyboardWillChange(notification:NSNotification) {
        let keyboardHeight = view.height - (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue.minY
        print((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue.minY)
        KeyboardOverlay.newTop = keyboardHeight
            commentFieldView.frame.origin.y = commentFieldView.frame.origin.y + (KeyboardOverlay.currentTop - KeyboardOverlay.newTop)
        
        KeyboardOverlay.currentTop = keyboardHeight
    }
    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        
        let label : UILabel = UILabel(frame: CGRect(x: 10,
                                                    y: 10,
                                                    width: view.frame.width / 3,
                                                    height: headerView.frame.height - 20))
        label.center = headerView.center
        label.textColor = .gray
        label.text = "コメント"
        label.textAlignment = .center
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    @objc private func didTapComment(){
        
    }
    
}

extension PostDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            guard let comments = comments else {
                
                return 1
            }
            return comments.count
        }
        return 0
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
            guard let comments = comments else {
                let cell = tableView.dequeueReusableCell(withIdentifier: NoCommentTableViewCell.identifier,
                                                         for: indexPath) as! NoCommentTableViewCell
                tableView.separatorStyle = .none
                
                return cell
                //                return UITableViewCell()
            }
            let comment = comments[indexPath.row]
            cell.configure(with: comment)
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
        //            return 25
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
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

extension PostDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //dbにcommentを投げる、コメントのtableをreloaddataする
        //textField.resignFirstResponder()
        didTapComment()
        return true
    }
    
}

