//
//  LoginViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/03.
//

import UIKit
import FirebaseAuth

class LoginRegisterViewController: UIViewController {

    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var registerStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginStackView.isHidden = false
        registerStackView.isHidden = true
    }

    @IBAction func didTapLogin(_ sender: Any) {
        
        guard let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty, !password.isEmpty else {
            alertUserLoginError(title: "エラー", message: "正しく情報を入力してください。")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self, error == nil else {
            self?.alertUserLoginError(title: "ログイン失敗", message: "ログインできませんでした。")
            return
          }
            strongSelf.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func didTapToRegister(_ sender: Any) {
        switch loginStackView.isHidden {
        case false:
            loginStackView.isHidden = true
            registerStackView.isHidden = false
        case true:
            loginStackView.isHidden = false
            registerStackView.isHidden = true
        }
    }
    
    @IBAction func didTapToLogin(_ sender: Any) {
        switch loginStackView.isHidden {
        case false:
            loginStackView.isHidden = true
            registerStackView.isHidden = false
        case true:
            loginStackView.isHidden = false
            registerStackView.isHidden = true
        }
    }
    func alertUserLoginError(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
}
