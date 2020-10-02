//
//  Post.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/02.
//

import Foundation

enum CommentType: String {
    case myCrush = "好きな人について"
    case exPartner = "元カノ元カレについて"
    case past = "過去について"
    case future = "将来について"
    case other = "その他"
}

struct Post {
    var userName: String
    var userImage: String?
    var commentType: CommentType
    var comment: String
    var postDate: Date
    var cheerCount: Int
}
