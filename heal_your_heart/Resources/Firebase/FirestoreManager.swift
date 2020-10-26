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
                self?.db.collection("users").document(ref.documentID).updateData(["userId": ref.documentID])
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
                self?.db.collection("posts").document(ref.documentID).updateData(["postId": ref.documentID])
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
                      //let imageUrl = dictionary["imageUrl"] as? URL,
                      let genre = dictionary["genre"] as? String,
                      let comment = dictionary["content"] as? String,
                      let postDate = dictionary["date"] as? Timestamp,
                      let postId = dictionary["postId"] as? String else {
                    return nil
                }
                
                let date = postDate.dateValue()
                return Post(userName: userId,
                            imageUrl: nil,
                            genre: genre as String,
                            comment: comment as String,
                            postDate: date as Date,
                            postId: postId,
                            userId: userId)
            }
            completion(.success(posts))
        }
    }
    
    public func getUserNameForPost(id: String, completion: @escaping ((Result<String, Error>) -> Void)) {
        
        db.collection("users").whereField("userId", isEqualTo: id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let nickname = document["nickname"] as? String {
                        completion(.success(nickname))
                    }
                }
            }
        }
    }
    
    public func sendComment(name: String, comment: String, postId: String, postUserId: String, commentUserId: String, completion: @escaping (Bool) -> Void) {
        var ref: DocumentReference? = nil
        ref = db.collection("comments").addDocument(data: [
            "name": name,
            "comment": comment,
            "date": Date(),
            "postId": postId,
            "postUserId": postUserId,
            "isRead": false,
            "commentUserId": commentUserId
        ]) { [weak self] err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                guard let ref = ref else {return}
                self?.db.collection("comments").document(ref.documentID).updateData(["commentId": ref.documentID])
                completion(true)
            }
        }
    }
    
    public func fetchComment(id: String, completion: @escaping (Result<[Comment], Error>) -> Void){
        db.collection("comments")
            .whereField("postId", isEqualTo: id)
            .order(by: "date", descending: true).getDocuments { (querySnapshot, err) in
                
                guard let value = querySnapshot?.documents else {
                    return
                }
                
                let comments : [Comment] = value.compactMap { dictionary in
                    
                    guard let comment = dictionary["comment"] as? String,
                          let postDate = dictionary["date"] as? Timestamp,
                          let commentId = dictionary["commentId"] as? String,
                          let isRead = dictionary["isRead"] as? Bool,
                          let postUserId = dictionary["postUserId"] as? String,
                          let postId = dictionary["postId"] as? String ,
                          let commentUserId = dictionary["commentUserId"] as? String else {
                        print("fetchComment failed")
                        return nil
                    }
                    
                    let date = postDate.dateValue()
                    
                    return Comment(comment: comment,
                                   postDate: date,
                                   commentId: commentId,
                                   isRead: isRead,
                                   postUserId: postUserId,
                                   postId: postId,
                                   commentUserId: commentUserId)
                }
                completion(.success(comments))
            }
    }
    
    public func searchPost(keyword: String, completion: @escaping (Result<[Post], Error>) -> Void){
        db.collection("posts").whereField("genre", isEqualTo: keyword).order(by: "date", descending: true).getDocuments { (querySnapshot, error) in
            guard let value = querySnapshot?.documents else {
                return
            }
            let posts: [Post] = value.compactMap { dictionary in
                
                guard let userId = dictionary["userId"] as? String,
                      let postId = dictionary["postId"] as? String,
                      let genre = dictionary["genre"] as? String,
                      let postDate = dictionary["date"] as? Timestamp,
                      let content = dictionary["content"] as? String else {
                    return nil
                }
                let date = postDate.dateValue()
                
                return Post(userName: userId,
                            imageUrl: nil,
                            genre: genre,
                            comment: content,
                            postDate: date,
                            postId: postId,
                            userId: userId)
            }
            completion(.success(posts))
        }
    }
    
    public func fetchCommentForNotification(id: String, completion: @escaping (Result<[Notification], Error>) -> Void){
        //自分のidを持った、isRead = FalseのCommmentを取得
        db.collection("comments")
            .whereField("isRead", isEqualTo: false)
            .whereField("postUserId", isEqualTo: id).order(by: "date", descending: true)
            .getDocuments { (querySnapshot, err) in
                
                guard let value = querySnapshot?.documents else {
                    return
                }
                
                let comments : [Notification] = value.compactMap { dictionary in
                    
                    guard let postDate = dictionary["date"] as? Timestamp,
                          let commentId = dictionary["commentId"] as? String,
                          let isRead = dictionary["isRead"] as? Bool,
                          let postUserId = dictionary["postUserId"] as? String,
                          let postId = dictionary["postId"] as? String ,
                          let commentUserId = dictionary["commentUserId"] as? String else {
                        print("fetchComment failed")
                        return nil
                    }
                    
                    let date = postDate.dateValue()
                    
                    return Notification(actionUserId: commentUserId,
                                        notificationId: commentId,
                                        date: date,
                                        isRead: isRead,
                                        postId: postId,
                                        postUserId: postUserId)
                }
                completion(.success(comments))
            }
    }
    
    public func fetchLikeForNotification(id: String, completion: @escaping (Result<[Notification], Error>) -> Void){
        //自分のidを持った、isRead = FalseのLikeを取得
        db.collection("likes")
            .whereField("isRead", isEqualTo: false)
            .whereField("postUserId", isEqualTo: id).order(by: "likeDate", descending: true).getDocuments { (querySnapshot, err) in
                
                guard let value = querySnapshot?.documents else {
                    return
                }
                
                let likes : [Notification] = value.compactMap { dictionary in
                    guard let likeDate = dictionary["likeDate"] as? Timestamp,
                          let postId = dictionary["postId"] as? String,
                          let isRead = dictionary["isRead"] as? Bool,
                          let postUserId = dictionary["postUserId"] as? String,
                          let likeId = dictionary["likeId"] as? String ,
                          let userId = dictionary["userId"] as? String else {
                        print("fetchLike failed")
                        return nil
                    }
                    
                    let date = likeDate.dateValue()
                    let like = Notification(actionUserId: userId,
                                            notificationId: likeId,
                                            date: date,
                                            isRead: isRead,
                                            postId: postId,
                                            postUserId: postUserId)
                    
                    return like
                }
                completion(.success(likes))
            }
    }
    
    public func fetchNotification(id: String, completion: @escaping (Result<[Notification], Error>) -> Void){
        var notifications = [Notification]()
        //自分のidを持った、isRead = FalseのLikeを取得
        
        db.collection("comments")
            .whereField("isRead", isEqualTo: false)
            .whereField("postUserId", isEqualTo: id).order(by: "date", descending: true)
            .getDocuments { [weak self](querySnapshot, err) in
                
                guard let value = querySnapshot?.documents else {
                    return
                }
                
                let comments : [Notification] = value.compactMap { dictionary in
                    
                    guard let postDate = dictionary["date"] as? Timestamp,
                          let commentId = dictionary["commentId"] as? String,
                          let isRead = dictionary["isRead"] as? Bool,
                          let postUserId = dictionary["postUserId"] as? String,
                          let postId = dictionary["postId"] as? String ,
                          let commentUserId = dictionary["commentUserId"] as? String else {
                        print("fetchComment failed")
                        return nil
                    }
                    
                    let date = postDate.dateValue()
                    
                    return Notification(actionUserId: commentUserId,
                                        notificationId: commentId,
                                        date: date,
                                        isRead: isRead,
                                        postId: postId,
                                        postUserId: postUserId)
                }
                notifications.append(contentsOf: comments)
                
                self?.db.collection("likes")
                    .whereField("isRead", isEqualTo: false)
                    .whereField("postUserId", isEqualTo: id).order(by: "likeDate", descending: true).getDocuments { (querySnapshot, err) in
                        
                        guard let value = querySnapshot?.documents else {
                            return
                        }
                        
                        let likes : [Notification] = value.compactMap { dictionary in
                            guard let likeDate = dictionary["likeDate"] as? Timestamp,
                                  let postId = dictionary["postId"] as? String,
                                  let isRead = dictionary["isRead"] as? Bool,
                                  let postUserId = dictionary["postUserId"] as? String,
                                  let likeId = dictionary["likeId"] as? String ,
                                  let userId = dictionary["userId"] as? String else {
                                print("fetchLike failed")
                                return nil
                            }
                            
                            let date = likeDate.dateValue()
                            let like = Notification(actionUserId: userId,
                                                    notificationId: likeId,
                                                    date: date,
                                                    isRead: isRead,
                                                    postId: postId,
                                                    postUserId: postUserId)
                            
                            return like
                        }
                        notifications.append(contentsOf: likes)
                    }
                completion(.success(notifications))
            }
    }
    
    public func makeIsReadTrue(commentId: String){
        let docRef = db.collection("comments").document(commentId)
        docRef.updateData([
            "isRead": true
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
    }
    //全てisReadをtrueにする関数 likeもいる！！！！！！！！！！！！！！！！！！！！！！！！
    public func makeAllIsReadTrue(id: String, completion: @escaping (Bool) -> Void){
        db.collection("comments").whereField("isRead", isEqualTo: false).whereField("postUserId", isEqualTo: id).getDocuments { [weak self] (querySnapShot, error) in
            guard let value = querySnapShot?.documents, error == nil else {
                return
            }
            
            for comment in value {
                let data = comment.data()
                guard let id = data["commentId"] as? String else {
                    return
                }
                let docRef = self?.db.collection("comments").document(id)
                guard let unwrappedRef = docRef else {
                    return
                }
                
                unwrappedRef.updateData([
                    "isRead": true
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        completion(true)
                    }
                }
                
            }
        }
    }
    
    public func getPost(by id: String, completion: @escaping (Result<Post, Error>) -> Void){
        db.collection("posts").document(id).getDocument { (snap, error) in
            guard let dictionary = snap?.data(), error == nil else {
                return
            }
            
            guard let genre = dictionary["genre"] as? String,
                  let comment = dictionary["content"] as? String,
                  let date = dictionary["date"] as? Timestamp,
                  let postId = dictionary["postId"] as? String,
                  let userId = dictionary["userId"] as? String else {
                return
            }
            let postDate = date.dateValue()
            
            let post = Post(userName: userId, imageUrl: nil, genre: genre, comment: comment, postDate: postDate, postId: postId, userId: userId)
            completion(.success(post))
        }
        
    }
    
    public func getMyPosts(by id: String, completion: @escaping (Result<[Post], Error>) -> Void){
        db.collection("posts").whereField("userId", isEqualTo: id).order(by: "date", descending: true).getDocuments { (snap, error) in
            guard let value = snap?.documents, error == nil else {
                return
            }
            
            let posts: [Post] = value.compactMap { dictionary in
                
                guard let userId = dictionary["userId"] as? String,
                      let postId = dictionary["postId"] as? String,
                      let genre = dictionary["genre"] as? String,
                      let postDate = dictionary["date"] as? Timestamp,
                      let content = dictionary["content"] as? String else {
                    return nil
                }
                let date = postDate.dateValue()
                
                return Post(userName: userId,
                            imageUrl: nil,
                            genre: genre,
                            comment: content,
                            postDate: date,
                            postId: postId,
                            userId: userId)
            }
            completion(.success(posts))
        }
    }
    
    public func checkLikeExist(userId: String, postId: String, completion: @escaping (String?) -> Void){
        db.collection("likes").whereField("userId", isEqualTo: userId).whereField("postId", isEqualTo: postId)
            .getDocuments() { (querySnapshot, err) in
                guard err == nil else {
                    print(err?.localizedDescription as Any)
                    return
                }
                
                for document in querySnapshot!.documents {
                    if document.exists {
                        completion(document.documentID)
                        return
                    }
                }
                
                if querySnapshot!.documents.isEmpty {
                    completion(nil)
                }
            }
        
    }
    
    public func getPostUserId(by postId: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("posts").whereField("postId", isEqualTo: postId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let userId = document["userId"] as? String {
                        completion(.success(userId))
                    }
                }
            }
        }
    }
    
    public func addLike(userId: String, postId: String, completion: @escaping (Int) -> Void){
        getPostUserId(by: postId, completion: { [weak self] result in
            switch result {
            case .success(let postUserId):
                var ref: DocumentReference? = nil
                ref = self?.db.collection("likes").addDocument(data: [
                    "userId": userId,
                    "postId": postId,
                    "likeDate": Date(),
                    "isRead": false,
                    "postUserId": postUserId
                ]) { [weak self] error in
                    if error == nil {
                        self?.db.collection("likes").document(ref!.documentID).updateData([
                            "likeId" : ref!.documentID
                        ])
                        self?.showLike(postId: postId, completion: { num in
                            completion(num)
                        })
                    } else {
                        print("addLike failed")
                    }
                }
            case .failure(_):
                print("getPostUserId failed")
            }
        })
        
        
    }
    
    public func deleteLike(likeId: String, postId: String, completion: @escaping (Int) -> Void){
        db.collection("likes").document(likeId).delete() { [weak self] err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                self?.showLike(postId: postId, completion: { num in
                    completion(num)
                })
            }
            
        }
    }
    
    public func showLike(postId: String, completion: @escaping (Int) -> Void){
        db.collection("likes").whereField("postId", isEqualTo: postId).getDocuments(completion: {
            (querySnapshot, err) in
            guard err == nil else {
                print(err?.localizedDescription as Any)
                return
            }
            
            if querySnapshot!.documents.isEmpty {
                completion(0)
            } else {
                completion(querySnapshot!.documents.count)
            }
        })
        
    }
    
    public func getUserEmail(by userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("users").whereField("userId", isEqualTo: userId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let email = document["email"] as? String {
                        completion(.success(email))
                    }
                }
            }
        }
    }
}

enum FirestoreError: Error {
    case failedToFetch
    case failedToUpload
}
