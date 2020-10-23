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
        tableView.register(PostTableViewCell.nib(),
                           forCellReuseIdentifier: PostTableViewCell.identifier)
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
    
    private let sendButton: UIButton = {
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
        
        let subviews = [commentTextField, sendButton]
        for x in subviews {
            commentFieldView.addSubview(x)
        }
        
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChange),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        guard let post = post else {return}
        FirestoreManager.shared.fetchComment(id: post.postId, completion: { [weak self] (result) in
            switch result {
            case .success(let comments):
                guard !comments.isEmpty else {
                    ///コメントが存在しないと真っ白
//                    self?.tableView.isHidden = true
                    return
                }
                
                self?.tableView.isHidden = false
                self?.comments = comments
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("fetchComment failed: \(error)")
            }
        })
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
        
        sendButton.frame = CGRect(x: 10 + commentTextField.frame.width + 10,
                                     y: 20,
                                     width: commentFieldView.frame.width - 30 - commentTextField.frame.width,
                                     height: 40)
    }
    
    func closeKeyboard() {
        commentTextField.endEditing(true)
    }
    
    @objc func keyboardWillChange(notification:NSNotification) {
        let keyboardHeight = view.height - (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue.minY
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
        label.text = ""
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    @objc private func didTapSend(){
        //firestoreにcommentを送る処理
        guard let name = UserDefaults.standard.value(forKey: "name") as? String,
              let comment = commentTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !comment.isEmpty else {
            return
        }
        
        guard let post = post else {
            return
        }
        
        guard let commentUserId = UserDefaults.standard.value(forKey: "id") as? String else {
            return
        }
        
        FirestoreManager.shared.sendComment(name: name, comment: comment, postId: post.postId, postUserId: post.userId, commentUserId: commentUserId, completion: { [weak self] success in
            if success {
                self?.commentTextField.resignFirstResponder()
                self?.commentTextField.text = ""
                
                FirestoreManager.shared.fetchComment(id: post.postId, completion: { [weak self] (result) in
                    switch result {
                    case .success(let comments):
                        guard !comments.isEmpty else {
                            self?.tableView.isHidden = true
                            return
                        }
                        
                        self?.tableView.isHidden = false
                        self?.comments = comments
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                        
                    case .failure(let error):
                        print("fetchComment failed: \(error)")
                        self?.tableView.isHidden = true
                    }
                })
                
            } else {
                let ac = UIAlertController(title: "エラー",
                                           message: "コメントできませんでした。",
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true, completion: nil)
            }
        })
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
            let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier,
                                                     for: indexPath) as! PostTableViewCell
            cell.selectionStyle = .none
            guard let post = post else {return UITableViewCell()}
            
            cell.configure(post: post)
            cell.post = post
            return cell
        } else {
            guard let comments = comments else {
                let cell = tableView.dequeueReusableCell(withIdentifier: NoCommentTableViewCell.identifier,
                                                         for: indexPath) as! NoCommentTableViewCell
                tableView.separatorStyle = .none
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier,
                                                     for: indexPath) as! CommentTableViewCell
            tableView.separatorStyle = .singleLine
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 50
        default:
            return 0
        }
    }
}

extension PostDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //dbにcommentを投げる、コメントのtableをreloaddataする
        //textField.resignFirstResponder()
        didTapSend()
        return true
    }
    
}

