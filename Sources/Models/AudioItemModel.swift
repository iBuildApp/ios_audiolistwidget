//
//  AudioItemModel.swift
//  AudioListModule
//
//  Created by Anton Boyarkin on 25/06/2019.
//

import Foundation
import IBACoreUI

class AudioItemModel: Decodable, CellModelType, Equatable {
    static func == (lhs: AudioItemModel, rhs: AudioItemModel) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.description == rhs.description && lhs.cover == rhs.cover && lhs.url == rhs.url && lhs.stream_url == rhs.stream_url && lhs.commentsCount == rhs.commentsCount
    }
    
    var id: Int64
    var title: String
    var description: String
    var cover: String
    var url: String
    var stream_url: String?
    
    var commentsCount: String = "0"
    
    enum CodingKeys: String, CodingKey {
        case id = "#id"
        case title = "#title"
        case description = "#description"
        case cover = "#cover_image"
        case url = "#permalink_url"
        case stream_url = "#stream_url"
    }
}

extension AudioItemModel {
    
    var coverImageUrl: URL? {
        guard !cover.isEmpty else { return nil }
        
        return URL(string: cover)
    }
    
}

extension AudioItemModel: CommentItemType {
    static var type: String = "audio"
}
