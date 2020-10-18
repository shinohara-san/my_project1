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
                self?.db.collection("users").document(ref.documentID).updateData(["selfId": ref.documentID])
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
        var ref: DocumentReference? = nil
        ref = db.collection("posts").addDocument(data: [
            "userId" : userId,
            "genre" : genre,
            "content" : content,
            "date": Date()
        ]) { [weak self](error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                guard let ref = ref else {return}
                self?.db.collection("posts").document(ref.documentID).updateData(["selfId": ref.documentID])
                completion(true)
            }
        }
    }
    
    public func fetchPostFromFirestore(completion: @escaping (Result<[Post], Error>) -> Void){
        
        db.collection("posts").order(by: "date", descending: true).getDocuments() { (querySnapshot, err) in
            guard let value = querySnapshot?.documents else {
                return
            }
            let posts : [Post] = value.compactMap { [weak self] dictionary in
                
                guard let userId = dictionary["userId"] as? String,
                      let username = self?.getUserName(id: userId), ///修正必要！！！
                      //let imageUrl = dictionary["imageUrl"] as? URL,
                      let genre = dictionary["genre"] as? String,
                      let comment = dictionary["content"] as? String,
                      let postDate = dictionary["date"] as? Timestamp,
                      let selfId = dictionary["selfId"] as? String else {
                    print("posts is nil")
                    return nil
                }
                let date = postDate.dateValue()
                return Post(userName: userId as String,
                            imageUrl: nil,
                            genre: genre as String,
                            comment: comment as String,
                            postDate: date as Date,
                            selfId: selfId,
                            userId: userId)
            }
            completion(.success(posts))
        }
    }
    
    public func getUserName(id: String) -> String {
        var username: String = ""
        db.collection("users").whereField("id", isEqualTo: id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let nickname = document["nickname"] as? String {
                        username = nickname
                    }
                }
            }
        }
        return username
    }
    
    public func sendComment(name: String, comment: String, parentId: String, completion: @escaping (Bool) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection("comments").addDocument(data: [
            "name": name,
            "comment": comment,
            "date": Date(),
            "parentId": parentId
        ]) { [weak self] err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                guard let ref = ref else {return}
                self?.db.collection("comments").document(ref.documentID).updateData(["selfId": ref.documentID])
                completion(true)
            }
        }
    }
    
    public func fetchComment(id: String, completion: @escaping (Result<[Comment], Error>) -> Void){
        db.collection("comments")
            .whereField("parentId", isEqualTo: id)
            .order(by: "date", descending: true).getDocuments { (querySnapshot, err) in
                
                guard let value = querySnapshot?.documents else {
                    return
                }
                
                let comments : [Comment] = value.compactMap { dictionary in
                    
                    guard let name = dictionary["name"] as? String,
                          let comment = dictionary["comment"] as? String,
                          let postDate = dictionary["date"] as? Timestamp,
                          let selfId = dictionary["selfId"] as? String else {
                        print("comments is nil")
                        return nil
                    }
                    
                    let date = postDate.dateValue()
                    
                    return Comment(userName: name,
                                   userImage: nil,
                                   comment: comment,
                                   postDate: date,
                                   postId: selfId)
                }
                completion(.success(comments))
            }
    }
    
}

enum FirestoreError: Error {
    case failedToFetch
    case failedToUpload
}
