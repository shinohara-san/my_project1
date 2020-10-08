//
//  ProfileViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/06.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let name = UserDefaults.standard.value(forKey: "name") as? String,
              let gender = UserDefaults.standard.value(forKey: "gender") as? String,
              let age = UserDefaults.standard.value(forKey: "age") as? String else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            let safeEmail = FirestoreManager.safeEmail(emailAdderess: email)
            let path = "images/\(safeEmail)"
            StorageManager.shared.downloadURL(for: path) { (result) in
                switch result {
                case .success(let url):
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                case .failure(let error):
                    print(error)
                    self?.userImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
            
            self?.nicknameLabel.text = name
            self?.emailLabel.text = email
            self?.genderLabel.text = gender
            self?.ageLabel.text = age
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.layer.cornerRadius = 64
    }
    
}
