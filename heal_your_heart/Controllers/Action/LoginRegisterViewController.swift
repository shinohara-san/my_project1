//
//  LoginRegisterViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/05.
//

import UIKit
import FirebaseAuth

class LoginRegisterViewController: UIViewController {
    
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var registerStackView: UIStackView!
    @IBOutlet weak var emailRegister: UITextField!
    @IBOutlet weak var genderRegister: UITextField!
    @IBOutlet weak var ageRegister: UITextField!
    @IBOutlet weak var nickNameRegister: UITextField!
    @IBOutlet weak var passRegister: UITextField!
    @IBOutlet weak var passCheck: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginStackView.isHidden = false
        registerStackView.isHidden = true
        imageView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePicture))
        imageView.addGestureRecognizer(gesture)
        
        DispatchQueue.main.async {[weak self] in
            self?.imageView.layer.cornerRadius = 45.5
        }
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
            FirestoreManager.shared.setMyProfileUserDefaults(email: email)
            strongSelf.dismiss(animated: false, completion: nil)
            return
        }
    }
    @IBAction func didTapRegister(_ sender: Any) {
        guard let email = emailRegister.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passRegister.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let checkedPassword = passCheck.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let age = ageRegister.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let gender = genderRegister.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let nickname = nickNameRegister.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty, !password.isEmpty, !age.isEmpty, !gender.isEmpty, !nickname.isEmpty,
              password == checkedPassword else {
            alertUserLoginError(title: "エラー", message: "正しく情報を入力してください。")
            return
        }
        
        
        FirestoreManager.shared.storeUserInfo(nickname: nickname, gender: gender, age: age, email: email){ [weak self] success in
            if success {
                
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    guard authResult != nil, error == nil else {
                        self?.alertUserLoginError(title: "登録できませんでした。", message:  "正しく情報を入力してください。")
                        return
                    }
                    let safeEmail = FirestoreManager.safeEmail(emailAdderess: email)
                    
                    if let image = self?.imageView.image,
                       let data = image.pngData() {
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: safeEmail) { (result) in
                            switch result {
                            case .success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        }
                    }
                    
                    FirestoreManager.shared.setMyProfileUserDefaults(email: email)
                    self?.dismiss(animated: true, completion: nil)
                }
            } else {
                self?.alertUserLoginError(title: "登録できませんでした。", message:  "正しく情報を入力してください。")
                return
            }
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
    
    @objc private func didTapChangeProfilePicture(){
        presentPhotoActionSheet()
    }
}

extension LoginRegisterViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private func presentPhotoActionSheet(){
        let ac = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        ac.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(ac, animated: true)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true //写真を四角で切り取れる
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary //上のとの違い
        vc.delegate = self
        vc.allowsEditing = true //写真を四角で切り取れる
        present(vc, animated: true)
    }
    
    //以下二つがUIImagePickerControllerDelegateに関する関数
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) //閉じるやつ
    }
}
