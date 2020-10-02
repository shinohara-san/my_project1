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
    
    private let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "新規投稿"
        genreTextField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "閉じる",
                                                            style: .done,
                                                            target: self,
                                                            action:#selector(didTapClose))
        
        genreTextField.borderStyle = .roundedRect
        
        setUpToolbar()
        setUpPickerView()
        
        // UITextField編集時に表示されるキーボードをpickerViewに置き換える
        let vi = UIView(frame: pickerView.bounds)
        vi.backgroundColor = UIColor.white
        vi.addSubview(pickerView)
        
        genreTextField.inputView = vi
    }
    
    @objc private func didTapClose(){
        
        let ac = UIAlertController(title: "入力を終了しますか？", message: "入力内容は保存されません。", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "終了する", style: .destructive, handler: { [weak self](_) in
            self?.dismiss(animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "入力を続ける", style: .cancel))
        present(ac, animated: true, completion: nil)
        
        
    }
    
    @objc func done() {
        genreTextField.endEditing(true)
    }
    
    private func setUpToolbar(){
        //DONEボタンの設定・配置
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        genreTextField.inputAccessoryView = toolbar
    }
    
    private func setUpPickerView(){
        pickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pickerView.bounds.size.height)
        pickerView.delegate = self
        pickerView.dataSource = self
        
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
