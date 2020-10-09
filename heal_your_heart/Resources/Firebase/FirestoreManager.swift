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
    
    public func postToFirestore(userId: String, genre: String, content: String, completion: @escaping (Bool) -> Void){
        db.collection("posts").addDocument(data: [
            "userId" : userId,
            "genre" : genre,
            "content" : content,
            "date": Date()
        ]) { (error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    public func fetchPostFromFirestore(completion: @escaping (Result<[Post], Error>) -> Void){
        
        db.collection("posts").order(by: "date", descending: true).getDocuments() { (querySnapshot, err) in
            guard let value = querySnapshot?.documents else {
                return
            }
            let posts : [Post] = value.compactMap { dictionary in
                guard let userId = dictionary["userId"] as? String,
//                      let imageUrl = dictionary["imageUrl"] as? URL,
                      let genre = dictionary["genre"] as? String,
                      let comment = dictionary["content"] as? String,
                      let postDate = dictionary["date"] as? Timestamp,
                      let date = postDate.dateValue() as? Date else {
                    print("posts is nil")
                    return nil
                }
                
                return Post(userName: userId as String,
                            imageUrl: nil,
                            genre: genre as String,
                            comment: comment as String,
                            postDate: date as Date)
            }
            print("posts@func: \(posts)")
            completion(.success(posts))
        }
    }
    
}

enum FirestoreError: Error {
    case failedToFetch
    case failedToUpload
}
