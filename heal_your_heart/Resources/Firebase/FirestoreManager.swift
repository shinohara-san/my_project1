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
    
    public func findMyProfile(email: String){
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                return
            }
            print(snapshot.documents)
        }
    }
    
}
