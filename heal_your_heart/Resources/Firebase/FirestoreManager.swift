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
    
    public func storeUserInfo(nickname: String, gender: String, age: String, email: String, completion: @escaping (Bool) -> Void){
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "nickname": nickname,
            "gender": gender,
            "age": age,
            "email": email
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                print("Document added with ID: \(ref!.documentID)")
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
                guard let name = data["nickname"] as? String,
                      let age = data["age"] as? String,
                      let gender = data["gender"] as? String else {
                    return
                }
                print("Setting userdefaults...\(name), \(age), \(gender)")
                UserDefaults.standard.setValue(name, forKey: "name")
                UserDefaults.standard.setValue(age, forKey: "age")
                UserDefaults.standard.setValue(gender, forKey: "gender")
                UserDefaults.standard.setValue(email, forKey: "email")
                
            }
        }
    }
    
}
