//
//  SettingsViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/09/30.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    private let sections = ["　一般", "　その他"]
    private let values = [["プロフィール", "自分の投稿一覧"], ["利用規約","プライバシーポリシー","ログアウト"]]
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "マイページ"
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

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label : UILabel = UILabel()
        label.textColor = .gray
        label.backgroundColor = .systemGroupedBackground
        label.text = sections[section]
        return label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0, 1 :
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = values[indexPath.section][indexPath.row]
            return cell
        default :
            return UITableViewCell()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0, 1 :
            return 50
        default :
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
            if let vc = storyboard?.instantiateViewController(identifier: "profileVC") as? ProfileViewController {
                navigationController?.pushViewController(vc, animated: true)
            }
            case 1:
                if let vc = storyboard?.instantiateViewController(identifier: "myPostVC") as? MyPostViewController {
                    navigationController?.pushViewController(vc, animated: true)
                }
            default:
                fatalError()
            }
            break
        case 1:
            switch indexPath.row {
            case 0:
                print("To terms of use")
                break
            case 1:
                print("To privacy policy")
                break
            case 2:
                let ac = UIAlertController(title: "ログアウト", message: "ログアウトしますか？", preferredStyle: .actionSheet)
                ac.addAction(UIAlertAction(title: "ログアウトする", style: .destructive, handler: { [weak self] _ in
                    if let vc = self?.storyboard?.instantiateViewController(identifier: "loginVC") as? LoginRegisterViewController {
                        
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                        } catch let signOutError as NSError {
                            print ("Error signing out: %@", signOutError)
                        }
                        
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: false, completion: nil)
                        
                        UserDefaults.standard.setValue("", forKey: "name")
                        UserDefaults.standard.setValue("", forKey: "age")
                        UserDefaults.standard.setValue("", forKey: "gender")
                        UserDefaults.standard.setValue("", forKey: "email")
                        UserDefaults.standard.setValue("", forKey: "profile_picture_url")
                        UserDefaults.standard.setValue("", forKey: "id")
                        
                        let UINavigationController = self?.tabBarController?.viewControllers?[0]
                        self?.tabBarController?.selectedViewController = UINavigationController
                        
                    }
                    
                }))
                ac.addAction(UIAlertAction(title: "ログアウトしない", style: .default, handler: nil))
                present(ac, animated: true, completion: nil)
                break
            default:
                fatalError()
                break
            }
        default:
            fatalError()
            break
        }
    }
}

