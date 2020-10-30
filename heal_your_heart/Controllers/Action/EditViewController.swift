//
//  EditViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/30.
//

import UIKit

class EditViewController: UIViewController {
    
    var userImage: UIImage?
    var name: String?
    var gender: String?
    var age: String?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
