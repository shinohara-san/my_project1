//
//  FirestoreManager.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/03.
//

import Foundation
import FirebaseFirestore

final class FirestoreManager {
    static let shared = FirestoreManager()
    private init() {} //これ使うと同時にいろんなところで使えなくすることができる
    private let db = Firestore.firestore()
    
    static func safeEmail(emailAdderess: String) -> String {
        var safeEmail = emailAdderess.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    public func storeUserInfo(nickname: String, gender: String, age: String, email: String, completion: @escaping (Bool) -> Void){
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "nickname": nickname,
            "gender": gender,
            "age": age,
            "email": email
        ]) { [weak self] err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                guard let ref = ref else {return}
                self?.db.collection("users").document(ref.documentID).updateData(["id": ref.documentID])
//                print("Document added with ID: \(ref!.documentID)")
                completion(true)
            }
        }
    }
    
    public func setMyProfileUserDefaults(email: String){
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                return
            }
            for data in snapshot.documents {
                let id = data.documentID
                guard let name = data["nickname"] as? String,
                      let age = data["age"] as? String,
                      let gender = data["gender"] as? String else {
                    return
                }
                UserDefaults.standard.setValue(name, forKey: "name")
                UserDefaults.standard.setValue(age, forKey: "age")
                UserDefaults.standard.setValue(gender, forKey: "gender")
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue(id, forKey: "id")
            }
        }
    }
}
