//
//  SettingsViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/09/30.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private let sections = ["　一般", "　その他"]
    private let values = [["プロフィール"], ["利用規約","プライバシーポリシー","ログアウト"]]
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "設定"
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
            print("To profile")
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
                print("Log Out")
                let ac = UIAlertController(title: "ログアウト", message: "ログアウトしますか？", preferredStyle: .actionSheet)
                ac.addAction(UIAlertAction(title: "ログアウトする", style: .destructive, handler: { [weak self] _ in
                    if let vc = self?.storyboard?.instantiateViewController(identifier: "loginVC") as? LoginViewController {
                        vc.modalPresentationStyle = .fullScreen
                        self?.present(vc, animated: false, completion: nil)
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

