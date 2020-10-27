//
//  Like.swift
//  heal_your_heart
//
//  Created by Yuki Shinohara on 2020/10/22.
//

import Foundation

struct Like {
    var userId: String
    var postId: String
    var likeId: String
    var likeDate: Date
    var isRead: Bool
    var postUserId: String
    var type: String
}

enum NotificationType {
    case like
    case comment
}
