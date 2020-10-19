//
//  SearchViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/09/30.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let dataList = [
        "人生について","恋愛について","仕事について","人間関係について",
        "自分について","その他"
    ]
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(PostTableViewCell.nib(),
                           forCellReuseIdentifier: PostTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "No Result"
        label.textAlignment = .center
        label.backgroundColor = .secondarySystemBackground
        return label
    }()
    
    var posts = [Post]()
    
    private var searchBar: UISearchBar!
    private let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupSearchBar()
        
        let views = [tableView, noResultLabel]
        for x in views {
            view.addSubview(x)
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        setUpToolbar()
        setUpPickerView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = view.bounds
    }
    
    private func setUpToolbar(){
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        searchBar.inputAccessoryView = toolbar
    }
    
    private func setUpPickerView(){
        pickerView.frame = CGRect(x: 0, y: 0,
                                  width: UIScreen.main.bounds.size.width,
                                  height: pickerView.bounds.size.height)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let customPicker = UIView(frame: pickerView.bounds)
        customPicker.backgroundColor = .systemGray6
        customPicker.addSubview(pickerView)
        
        let searchTextField = searchBar.value(forKey: "searchField") as! UITextField
        searchTextField.inputView = customPicker
    }
    
    @objc func done() {
        searchBar.endEditing(true)
        guard let keyword = searchBar.text,
              !keyword.isEmpty else {
            return
        }
        FirestoreManager.shared.searchPost(keyword: keyword, completion: {[weak self] result in
            switch result {
            
            case .success(let posts):
                guard !posts.isEmpty else {
                    print("posts is empty")
                    self?.tableView.isHidden = true
                    self?.noResultLabel.isHidden = false
                    return
                }
                
                self?.noResultLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.posts = posts
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("failed to get posts!!: \(error)")
                self?.tableView.isHidden = true
                self?.noResultLabel.isHidden = false
            }
        })
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier,
                                                 for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.configure(post: post)
        cell.delegate = self
        cell.post = post
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

extension SearchViewController: PostTableViewCellDelegate {
    func moveToDetail(post: Post) {
        let vc = PostDetailViewController(post: post)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func setupSearchBar() {
        if let navigationBarFrame = navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.tintColor = UIColor.gray
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return dataList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        searchBar.text = dataList[row]
        
    }
}

