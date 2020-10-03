//
//  PostViewController.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/09/30.
//

import UIKit

class PostViewController: UIViewController {
    
    private let dataList = [
        "人生について","恋愛について","仕事について","人間関係について",
        "自分について","その他"
    ]
    
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    private let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genreTextField.delegate = self
        userImageView.contentMode = .scaleAspectFit
        
        commentTextView.delegate = self
        commentTextView.becomeFirstResponder()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "キャンセル",
                                                            style: .done,
                                                            target: self,
                                                            action:#selector(didTapClose))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "投稿する",
                                                            style: .done,
                                                            target: self,
                                                            action:#selector(didTapPost))
        
        genreTextField.borderStyle = .roundedRect
        
        setUpToolbar()
        setUpPickerView()

    }
    
    @objc private func didTapClose(){
        
        let ac = UIAlertController(title: "入力を終了しますか？", message: "入力内容は保存されません。", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "終了する", style: .destructive, handler: { [weak self](_) in
            self?.dismiss(animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "入力を続ける", style: .cancel))
        present(ac, animated: true, completion: nil)
        
        
    }
    
    @objc private func didTapPost(){
        let ac = UIAlertController(title: "投稿しますか？", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "投稿する", style: .default, handler: { [weak self](_) in
            //投稿する処理
            self?.dismiss(animated: true, completion: nil) //成功時
        }))
        ac.addAction(UIAlertAction(title: "入力を続ける", style: .default))
        present(ac, animated: true, completion: nil)
        
    }
    
    @objc func done() {
        genreTextField.endEditing(true)
        commentTextView.becomeFirstResponder()
    }
    
    private func setUpToolbar(){
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        genreTextField.inputAccessoryView = toolbar
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
        
        genreTextField.inputView = customPicker
    }
    
}

extension PostViewController: UITextFieldDelegate {
    
}

extension PostViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
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
        
        genreTextField.text = dataList[row]
        
    }
    
}

extension PostViewController: UITextViewDelegate {
    
}
