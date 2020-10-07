//
//  ProfileViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/06.
//

import UIKit

class ProfileViewController: UIViewController {
    
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
            self?.nicknameLabel.text = name
            self?.emailLabel.text = email
            self?.genderLabel.text = gender
            self?.ageLabel.text = age
        }
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
}
