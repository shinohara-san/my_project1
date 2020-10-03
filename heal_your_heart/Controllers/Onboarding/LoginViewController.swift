//
//  LoginViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/03.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func didTapLogin(_ sender: Any) {
        
    }
    
    @IBAction func didTapToRegister(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(identifier: "registerVC") as? RegisterViewController{
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false, completion: nil)
        }
    }
    
    
}
