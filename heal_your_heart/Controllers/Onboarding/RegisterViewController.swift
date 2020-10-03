//
//  RegisterViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/03.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var generationField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var checkPasswordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapRegister(_ sender: Any) {
    }
    @IBAction func didTapToLogin(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "loginVC") as? LoginViewController {
            vc.modalPresentationStyle = .fullScreen
            present(vc,animated: false)
        }
    }
    

}
